#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import sys
from time import sleep

from plumbum.cmd import notify_send
from requests import get
from requests.exceptions import ConnectionError

from vault import DARKSKY_API_KEY, LAT, LONG


API_BASE = f'https://api.darksky.net/forecast/{DARKSKY_API_KEY}/{LAT},{LONG}'
ICONS = {
    'rain':                '',
    'snow':                '',
    'sleet':               '',
    'clear-day':           '',
    'clear-night':         '',
    'wind':                '',
    'fog':                 '',
    'cloudy':              '',
    'partly-cloudy-day':   '',
    'partly-cloudy-night': ''
}


def colorize(text, colorhex='#B8BB26'):
    return f"<font color=\"#{colorhex.lstrip('#')}\">{text}</font>"


def notify():
    try:
        r = get(
            f"{API_BASE}",
            params={
                'exclude': 'currently,daily,alerts,flags',
                'units': 'uk2'
            }
        )
    except ConnectionError as e:
        notify_send('-a', "Weather", e)
    else:
        hourly, minutely = r.json()['hourly'], r.json()['minutely']
        body = f"{minutely['summary']}\n{hourly['summary']}"
        title_icon = ICONS[hourly['icon']]
        summary = ""
        for hour in hourly['data']:
            i = ICONS[hour['icon']]
            if not summary or i != summary[-1]:
                summary += i
        notify_send('-a', f"Weather {title_icon}", summary, body)


def display():
    for attempt in range(3):
        try:
            r = get(
                f"{API_BASE}",
                params={
                    'exclude': 'minutely,hourly,daily,alerts,flags',
                    'units': 'uk2'
                }
            )
        except ConnectionError:
            sleep(6)
        else:
            current = r.json()['currently']
            temp = round(current['temperature'])
            icon = ICONS[current['icon']]
            print(colorize(f"{temp}°{icon}"))
            break


if __name__ == '__main__':
    if '--click' in sys.argv[1:]:
        notify()
    else:
        display()

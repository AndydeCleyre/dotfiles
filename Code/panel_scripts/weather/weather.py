#!/home/andy/.local/bin/vpy
#!/usr/bin/env python3
import sys
from time import sleep
from contextlib import suppress

from plumbum import local, CommandNotFound, ProcessExecutionError
from plumbum.cmd import notify_send
import httpx

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


def notify():
    try:
        r = httpx.get(API_BASE, params={
            'exclude': 'currently,daily,alerts,flags',
            'units': 'uk2'
        })
    except httpx.exceptions.NetworkError as e:
        notify_send('-a', "Weather", '-t', 30000, "Network Error", e)
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
    try:
        with suppress(CommandNotFound):
            local['nm-online']('-x')
    except ProcessExecutionError:
        print("")
    else:
        for attempt in range(3):
            try:
                r = httpx.get(API_BASE, params={
                    'exclude': 'minutely,hourly,daily,alerts,flags',
                    'units': 'uk2'
                })
            except httpx.exceptions.NetworkError as e:
                # notify_send('-a', "Weather", '-t', 30000, "Network Error", e)
                notify_send('-a', "Weather", "Network Error", e)
                # notify_send('-a', "Weather", "Network Error")
                sleep(2)
            else:
                current = r.json()['currently']
                temp = round(current['temperature'])
                icon = ICONS[current['icon']]
                print(f"{temp}°{icon}")
                break
        else:
            print("")


if __name__ == '__main__':
    # if '--debug' not in sys.argv[1:]:
        # sleep(30)
        # sys.exit()
    if '--click' in sys.argv[1:]:
        notify()
    else:
        display()

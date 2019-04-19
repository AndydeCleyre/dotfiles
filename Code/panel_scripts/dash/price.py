#!/usr/bin/env python3
from sys import argv
from time import sleep

from requests import get
from requests.exceptions import ConnectionError


def colorize(text, colorhex='6d948d'):
    return text
    # return f'<font color="#{colorhex}">{text}</font>'


if len(argv) > 1:
    print(colorize("---"))
else:
    API_BASE = 'https://min-api.cryptocompare.com'
    for attempt in range(3):
        try:
            r = get(f"{API_BASE}/data/price", params={'fsym': 'DASH', 'tsyms': 'USD'})
        except ConnectionError:
            sleep(6)
        else:
            price = r.json()['USD']
            print(colorize(f"${price:.2f}"))
            break

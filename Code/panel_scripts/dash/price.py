#!/usr/bin/env python3
from sys import argv
from time import sleep

from requests import get
from requests.exceptions import ConnectionError


if len(argv) > 1:
    print("🙈")
else:
    API_BASE = 'https://min-api.cryptocompare.com'
    while True:
        try:
            r = get(f"{API_BASE}/data/price", params={'fsym': 'DASH', 'tsyms': 'USD'})
        except ConnectionError:
            sleep(10)
        else:
            break
    price = r.json()['USD']
    print('{', f"${price:.2f}", '}')

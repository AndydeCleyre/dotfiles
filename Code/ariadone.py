#!/usr/bin/env python3
from plumbum import local
fs = local.cwd.list()
print(*[f.relative_to(local.cwd) for f in fs if not (f.endswith('.aria2') or f"{f}.aria2" in fs)], sep='\n')

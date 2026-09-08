#!/usr/bin/env python3

import json
import sys
from pathlib import Path

version_file = Path(sys.argv[1])
version_data = json.loads(version_file.read_text(encoding="utf-8"))
print(f"UE_{version_data["MajorVersion"]}.{version_data["MinorVersion"]}", end="")

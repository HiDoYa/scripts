#!/usr/local/bin/python3

# Installation:
#   Copy to /usr/local/bin, chmod +x, and remove the .py suffix

from datetime import datetime
import sys

if len(sys.argv) != 2:
    print("Usage: changelog-inc 1.0.3")
    exit()

version = sys.argv[1]

with open("CHANGELOG.md", "r") as f:
    changelog = f.readlines()

header = "".join(changelog[:6])
tail = "".join(changelog[6:])
date = datetime.today().strftime("%Y-%m-%d")

new_version = f"""
## [{version}] - {date}
### Added
- N/A
### Changed
- N/A
### Deprecated
- N/A
### Fixed
- N/A
### Removed
- N/A
"""

new_changelog = header + new_version + tail

with open("CHANGELOG.md", "w") as f:
    f.write(new_changelog)

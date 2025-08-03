#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

# Installation
# sudo cp vupdate.py /usr/local/bin/vupdate

import os
import sys
import subprocess
from enum import Enum, auto


class ProjectVersionTypes(Enum):
    UV = auto()
    POETRY = auto()
    VERSION = auto()


def find_project_type():
    if os.path.isfile("uv.lock"):
        return ProjectVersionTypes.UV
    elif os.path.isfile("poetry.lock"):
        return ProjectVersionTypes.POETRY
    else:
        return ProjectVersionTypes.VERSION


def find_version_file():
    if os.path.isfile("VERSION"):
        return "VERSION"
    elif os.path.isfile(os.path.join("app", "VERSION")):
        return os.path.join("app", "VERSION")

    for entry in os.listdir("."):
        if os.path.isdir(entry):
            version_file = os.path.join(entry, "VERSION")
            if os.path.isfile(version_file):
                return version_file

    return None


def get_version_file_prefix(version_file):
    prefix = ""
    with open(version_file, "r") as f:
        current = f.read().strip()
        if current.startswith("v"):
            prefix = "v"
    return prefix


def run_command(cmd):
    result = subprocess.run(
        cmd,
        shell=True,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    return result.stdout.strip()


def main():
    if len(sys.argv) != 2:
        print("Usage: vupdate <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    version.replace("v", "")

    project_type = find_project_type()
    if project_type == ProjectVersionTypes.UV:
        run_command(f"uv version {version}")
        print(f"uv version set to {version}")
    elif project_type == ProjectVersionTypes.POETRY:
        run_command(f"poetry version {version}")
        print(f"Poetry version set to {version}")
    elif project_type == ProjectVersionTypes.VERSION:
        version_file = find_version_file()
        if not version_file:
            print("VERSION file not found.", file=sys.stderr)
            sys.exit(1)

        prefix = get_version_file_prefix(version_file)
        full_version = f"{prefix}{version}"

        # Write version
        with open(version_file, "w") as f:
            f.write(full_version)
        print(f"Updated {version_file} to {full_version}")

    # Update changelog
    run_command(f"changelog-inc {version}")
    print("Changelog updated")


if __name__ == "__main__":
    main()

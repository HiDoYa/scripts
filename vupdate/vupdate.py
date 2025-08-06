#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "semver",
# ]
# ///

# Installation
# sudo cp vupdate.py /usr/local/bin/vupdate

import os
import sys
import subprocess
import semver
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


def get_current_version(project_type, version_file=None):
    if project_type == ProjectVersionTypes.UV:
        return run_command("uv version --short")
    elif project_type == ProjectVersionTypes.POETRY:
        return run_command("poetry version -s")
    elif project_type == ProjectVersionTypes.VERSION:
        with open(version_file) as f:
            return f.read().removeprefix("v").strip()


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
    project_type = find_project_type()
    version_file = None
    if project_type == ProjectVersionTypes.VERSION:
        version_file = find_version_file()
        if not version_file:
            print("VERSION file not found.", file=sys.stderr)
            sys.exit(1)

    current_version = get_current_version(project_type, version_file)
    print(f"Current version: {current_version}")

    if len(sys.argv) == 2:
        new_version = sys.argv[1]
        new_version.replace("v", "")
    else:
        new_version = semver.Version.parse(current_version).bump_patch()

    if project_type == ProjectVersionTypes.UV:
        run_command(f"uv version {new_version}")
        print(f"uv version set: {new_version}")
    elif project_type == ProjectVersionTypes.POETRY:
        run_command(f"poetry version {new_version}")
        print(f"Poetry version set: {new_version}")
    elif project_type == ProjectVersionTypes.VERSION:
        prefix = get_version_file_prefix(version_file)
        full_version = f"{prefix}{new_version}"

        with open(version_file, "w") as f:
            f.write(full_version)
        print(f"File version set: {full_version}")

    # Update changelog
    run_command(f"changelog-inc {new_version}")
    print("Changelog updated")


if __name__ == "__main__":
    main()

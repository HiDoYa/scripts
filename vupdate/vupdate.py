#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "semver>=3.0.4",
#     "toml>=0.10.2",
# ]
# ///

# Installation
# sudo cp vupdate.py /usr/local/bin/vupdate

import os
import sys
import subprocess
import semver
import json
import toml
from enum import Enum, auto


class ProjectVersionTypes(Enum):
    VERSION = auto()
    UV = auto()
    POETRY = auto()
    NODE = auto()
    CARGO = auto()


def find_project_type():
    if version_file := find_version_file():
        return ProjectVersionTypes.VERSION, version_file
    if os.path.isfile("uv.lock"):
        return ProjectVersionTypes.UV, "pyproject.toml"
    elif os.path.isfile("poetry.lock"):
        return ProjectVersionTypes.POETRY, "pyproject.toml"
    elif os.path.isfile("package.json"):
        return ProjectVersionTypes.NODE, "package.json"
    elif os.path.isfile("Cargo.toml"):
        return ProjectVersionTypes.CARGO, "Cargo.toml"


def find_version_file():
    for version_path in ["VERSION", "app/VERSION", "src/VERSION"]:
        if os.path.isfile(version_path):
            return version_path
    return None


def get_version_file_prefix(version_file):
    prefix = ""
    with open(version_file, "r") as f:
        current = f.read().strip()
        if current.startswith("v"):
            prefix = "v"
    return prefix


def get_current_version(project_type, version_file):
    if project_type == ProjectVersionTypes.VERSION:
        with open(version_file) as f:
            return f.read().removeprefix("v").strip()
    elif project_type == ProjectVersionTypes.UV:
        return run_command("uv version --short")
    elif project_type == ProjectVersionTypes.POETRY:
        return run_command("poetry version -s")
    elif project_type == ProjectVersionTypes.NODE:
        with open("package.json", "r") as f:
            return json.load(f)["version"]
    elif project_type == ProjectVersionTypes.CARGO:
        with open("Cargo.toml", "r") as f:
            return toml.load(f)["package"]["version"]


def get_new_version(current_version):
    if len(sys.argv) == 2:
        new_version = sys.argv[1]
        new_version.replace("v", "")
    else:
        new_version = str(semver.Version.parse(current_version).bump_patch())

    return new_version


def set_version(project_type, new_version, version_file=None):
    if project_type == ProjectVersionTypes.VERSION:
        prefix = get_version_file_prefix(version_file)
        full_version = f"{prefix}{new_version}"
        with open(version_file, "w") as f:
            f.write(full_version)
        print(f"file version set")
    elif project_type == ProjectVersionTypes.UV:
        run_command(f"uv version {new_version}")
        print(f"uv version set")
    elif project_type == ProjectVersionTypes.POETRY:
        run_command(f"poetry version {new_version}")
        print(f"poetry version set")
    elif project_type == ProjectVersionTypes.NODE:
        with open(version_file, "r") as f:
            file_content = json.load(f)
            file_content["version"] = new_version
        with open(version_file, "w") as f:
            json.dump(file_content, f, indent=4)
        print(f"node version set")
    elif project_type == ProjectVersionTypes.CARGO:
        with open(version_file, "r") as f:
            file_content = toml.load(f)
            file_content["package"]["version"] = new_version
        with open(version_file, "w") as f:
            toml.dump(file_content, f)


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
    project_type, version_file = find_project_type()

    current_version = get_current_version(project_type, version_file)
    print(f"Current version: {current_version}")

    new_version = get_new_version(current_version)
    print(f"New version: {new_version}")

    set_version(project_type, new_version, version_file)

    # Update changelog
    run_command(f"changelog-inc {new_version}")
    print("Changelog updated")


if __name__ == "__main__":
    main()

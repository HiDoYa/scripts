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
import re
import xml.etree.ElementTree as ET
from enum import Enum, auto


class ProjectVersionTypes(Enum):
    UV = auto()
    POETRY = auto()
    VERSION = auto()
    NODE_PACKAGE_JSON = auto()
    RUST_CARGO = auto()
    GO_MOD = auto()
    RUBY_GEMSPEC = auto()
    DOTNET_CSPROJ = auto()
    DOTNET_FSPROJ = auto()


def find_project_type():
    if os.path.isfile("uv.lock"):
        return ProjectVersionTypes.UV
    elif os.path.isfile("poetry.lock"):
        return ProjectVersionTypes.POETRY
    elif os.path.isfile("package.json"):
        return ProjectVersionTypes.NODE_PACKAGE_JSON
    elif os.path.isfile("Cargo.toml"):
        return ProjectVersionTypes.RUST_CARGO
    elif os.path.isfile("go.mod"):
        return ProjectVersionTypes.GO_MOD
    elif any(f.endswith('.gemspec') for f in os.listdir('.') if os.path.isfile(f)):
        return ProjectVersionTypes.RUBY_GEMSPEC
    elif any(f.endswith('.csproj') for f in os.listdir('.') if os.path.isfile(f)):
        return ProjectVersionTypes.DOTNET_CSPROJ
    elif any(f.endswith('.fsproj') for f in os.listdir('.') if os.path.isfile(f)):
        return ProjectVersionTypes.DOTNET_FSPROJ
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


def find_gemspec_file():
    for f in os.listdir('.'):
        if os.path.isfile(f) and f.endswith('.gemspec'):
            return f
    return None


def find_project_file(extension):
    for f in os.listdir('.'):
        if os.path.isfile(f) and f.endswith(extension):
            return f
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
    elif project_type == ProjectVersionTypes.NODE_PACKAGE_JSON:
        with open("package.json", "r") as f:
            data = json.load(f)
            return data.get("version", "0.1.0")
    elif project_type == ProjectVersionTypes.RUST_CARGO:
        with open("Cargo.toml", "r") as f:
            data = toml.load(f)
            return data["package"]["version"]
    elif project_type == ProjectVersionTypes.GO_MOD:
        with open("go.mod", "r") as f:
            content = f.read()
            # Look for version in module path (e.g., module example.com/foo/v2)
            match = re.search(r'module\s+\S+/v(\d+)', content)
            if match:
                major_version = match.group(1)
                return f"{major_version}.0.0"  # Default for Go modules
            raise Exception("No version found")
    elif project_type == ProjectVersionTypes.RUBY_GEMSPEC:
        gemspec_file = find_gemspec_file()
        if gemspec_file:
            with open(gemspec_file, "r") as f:
                content = f.read()
                # Look for version assignment in gemspec
                regex_str = r'version\s*=\s*["\']([^"\']*)["\']'
                match = re.search(regex_str, content)
                if match:
                    return match.group(1)
        raise Exception("No version found")
    elif project_type in [ProjectVersionTypes.DOTNET_CSPROJ, ProjectVersionTypes.DOTNET_FSPROJ]:
        extension = '.csproj' if project_type == ProjectVersionTypes.DOTNET_CSPROJ else '.fsproj'
        project_file = find_project_file(extension)
        if project_file:
            tree = ET.parse(project_file)
            root = tree.getroot()
            version_elem = root.find('.//Version')
            if version_elem is not None and version_elem.text:
                return version_elem.text
        raise Exception("No version found")


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

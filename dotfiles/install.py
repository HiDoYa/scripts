#!/usr/bin/python3
# This script is left intentionally minimal to ensure it can be ran on any new setup with no other dependencies

RED = '\033[31m'
GREEN = '\033[32m'
RESET = '\033[0m'
BLUE = '\033[34m'

import os
import argparse
import shutil
import difflib

HOME = os.getenv("HOME")


def get_contents(dirname, mode):
    abs_dir = os.path.realpath(os.path.dirname(__file__)) + "/" + dirname
    files = os.listdir(abs_dir)
    files.sort()
    contents = ""

    for file in files:
        if "general" not in file and mode not in file:
            continue

        fname = f"{abs_dir}/{file}"
        with open(fname, "r") as f:
            contents += f.read()
            contents += "\n\n"

    return contents


def write_to_file(contents, dest_file):
    with open(dest_file, "w") as f:
        f.write(contents)

def write_to_file_with_prompt(contents, dest_file):
    answer = ""
    while answer not in ["y", "n"]:
        answer = input(f"{GREEN}Confirm the changes?{RESET} (y/n): ").strip().lower()

    if answer == "y":
        write_to_file(contents, dest_file)
        print(f"{GREEN}Contents written to file: {dest_file}{RESET}")
    else:
        print(f"{RED}Skipping file write...{RESET}")
    
def copy_to_file_with_prompt(src_fname, dst_fname):
    print()
    answer = ""
    while answer not in ["y", "n"]:
        answer = input(f"{GREEN}Confirm the changes?{RESET} (y/n): ").strip().lower()

    if answer == "y":
        os.makedirs(os.path.dirname(dst_fname), exist_ok=True)
        shutil.copyfile(src_fname, dst_fname)
        print(f"{GREEN}Contents written to file: {dst_fname}{RESET}")
    else:
        print(f"{RED}Skipping file write...{RESET}")


def print_diff(existing_file, new_file):
    if not os.path.isfile(existing_file):
        print(f"{RED}File does not currently exist{RESET}")
        # There is always a diff if original file DNE
        return True

    with open(existing_file) as existing_fd:
        with open(new_file) as new_fd:
            diff = difflib.unified_diff(
                existing_fd.readlines(),
                new_fd.readlines(),
                fromfile='existing_file',
                tofile='new_file'
            )

            diff = list(diff)
            for line in diff:
                if line.startswith('+'):
                    print(f"{GREEN}{line}{RESET}", end="")
                elif line.startswith('-'):
                    print(f"{RED}{line}{RESET}", end="")
                elif line.startswith('?'):
                    print(f"{BLUE}{line}{RESET}", end="")
                else:
                    print(line, end="")
                    
            changed = len(diff) != 0
            return changed

def dotfile_workflow(config_src_dir, temp_file, config_file):
    contents = get_contents(config_src_dir, args.mode)
    write_to_file(contents, temp_file)
    changed = print_diff(config_file, temp_file)
    if changed:
        write_to_file_with_prompt(contents, config_file)
    else:
        print(f"{RED}No changed detected for {config_src_dir}{RESET}")

def direct_copy_workflow(config_src_dir, config_dir):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    abs_config_src_dir = f"{script_dir}/{config_src_dir}"
    files = os.listdir(abs_config_src_dir)
    files.sort()

    for file in files:
        src_fname = f"{abs_config_src_dir}/{file}"
        dst_fname = f"{config_dir}/{file}"

        changed = print_diff(dst_fname, src_fname)
        if changed:
            copy_to_file_with_prompt(src_fname, dst_fname)
        else:
            print(f"{RED}No changed detected for {config_src_dir} {file}{RESET}")


parser = argparse.ArgumentParser()
parser.add_argument("mode", help="Must be work or home")
args = parser.parse_args()

if args.mode not in ["work", "home"]:
    print("Mode must be work or home")
    exit(1)

script_dir = os.path.dirname(os.path.abspath(__file__))
temp_dir = f"{script_dir}/temp"
os.makedirs(temp_dir, exist_ok=True)

dotfile_workflow("zshrc", f"{temp_dir}/.zshrc", f"{HOME}/.zshrc")
dotfile_workflow("gitconfig", f"{temp_dir}/.gitconfig", f"{HOME}/.gitconfig")

direct_copy_workflow("vimrc", f"{HOME}")
direct_copy_workflow("tmux", f"{HOME}")
direct_copy_workflow("alacritty", f"{HOME}/.config/alacritty")
direct_copy_workflow("atuin", f"{HOME}/.config/atuin")
direct_copy_workflow("vscode", f"{HOME}/Library/Application Support/Code/User")

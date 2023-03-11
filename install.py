#!/usr/bin/python3

import os
import argparse

HOME = os.getenv("HOME")

def get_contents(dirname, mode):
    files = os.listdir(dirname)
    contents = ""

    for file in files:
        if 'general' not in file and mode not in file:
            continue

        fname = f"{dirname}/{file}"
        with open(fname, 'r') as f:
            contents += f.read()
            contents += '\n\n'

    return contents

def write_to_file(contents, dest_file):
    with open(dest_file, 'w') as f:
        f.write(contents)
    print(f"Contents written to file: {dest_file}")

parser = argparse.ArgumentParser()
parser.add_argument("mode", help="Must be work or home")
args = parser.parse_args()

contents = get_contents("zshrc", args.mode)
write_to_file(contents, f"{HOME}/.zshrc")

contents = get_contents("vimrc", args.mode)
write_to_file(contents, f"{HOME}/.vimrc")

contents = get_contents("gitconfig", args.mode)
write_to_file(contents, f"{HOME}/.gitconfig")
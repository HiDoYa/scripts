#!/usr/bin/python3

import os
import argparse
import shutil

HOME = os.getenv("HOME")


def get_contents(dirname, mode):
    files = os.listdir(dirname)
    files.sort()
    contents = ""

    for file in files:
        if "general" not in file and mode not in file:
            continue

        fname = f"{dirname}/{file}"
        with open(fname, "r") as f:
            contents += f.read()
            contents += "\n\n"

    return contents


def write_to_file(contents, dest_file):
    with open(dest_file, "w") as f:
        f.write(contents)
    print(f"Contents written to file: {dest_file}")


def copy_direct(srcdir, dstdir):
    files = os.listdir(srcdir)
    files.sort()

    for file in files:
        src_fname = f"{srcdir}/{file}"
        dst_fname = f"{dstdir}/{file}"

        shutil.copyfile(src_fname, dst_fname)
        print(f"Contents written to file: {dst_fname}")


parser = argparse.ArgumentParser()
parser.add_argument("mode", help="Must be work or home")
args = parser.parse_args()

contents = get_contents("zshrc", args.mode)
write_to_file(contents, f"{HOME}/.zshrc")

contents = get_contents("vimrc", args.mode)
write_to_file(contents, f"{HOME}/.vimrc")

contents = get_contents("gitconfig", args.mode)
write_to_file(contents, f"{HOME}/.gitconfig")

contents = get_contents("alacritty", args.mode)
write_to_file(contents, f"{HOME}/.alacritty")

copy_direct("vscode", f"{HOME}/Library/Application Support/Code/User")

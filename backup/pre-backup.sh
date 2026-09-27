#!/bin/bash
# resticprofile run-before: wait for NAS, dump pkg lists into backup source
set -uo pipefail

OUT=$HOME/.local/share/pkg-backup

eval "$(/opt/homebrew/bin/brew shellenv)"

# launchd may fire right after wake, before network is up
for i in {1..30}; do
	ssh -o BatchMode=yes -o ConnectTimeout=5 store true 2>/dev/null && break
	[[ $i == 30 ]] && { echo "NAS unreachable" >&2; exit 1; }
	sleep 10
done

mkdir -p "$OUT"
brew bundle dump --file="$OUT/Brewfile" --force >/dev/null 2>&1 || echo "WARN: brew bundle failed" >&2
command -v gem >/dev/null && gem list > "$OUT/gem.txt"
command -v npm >/dev/null && npm ls -g --depth=0 > "$OUT/npm.txt" 2>/dev/null
command -v pip3 >/dev/null && pip3 freeze > "$OUT/pip.txt" 2>/dev/null
exit 0

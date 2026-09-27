#!/bin/bash
# Backs up secrets + pkg lists to Google Drive as timestamped tarballs.
# Usage: backup.sh [secrets|pkg]  (default: both)
set -uo pipefail

RCLONE_CONF=$HOME/.config/rclone/rclone.conf
REMOTE=MainDrive:/Backup
RETENTION=365d
STAMP=$(date +%Y-%m-%d-%H%M)
RCLONE=(rclone --config "$RCLONE_CONF" --retries 5 --low-level-retries 20)

eval "$(/opt/homebrew/bin/brew shellenv)"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

log() { echo "$(date '+%F %T') $*"; }

fail() {
	log "ERROR: $*" >&2
	osascript -e "display notification \"$*\" with title \"Backup failed\"" 2>/dev/null
	exit 1
}

# launchd may fire right after wake, before network is up
wait_for_network() {
	for _ in {1..30}; do
		host -W 2 www.googleapis.com >/dev/null 2>&1 && return
		sleep 10
	done
	fail "no network"
}

# Fail fast on expired token instead of partway through
check_auth() {
	"${RCLONE[@]}" lsd "$REMOTE" >/dev/null 2>&1 \
		|| fail "rclone auth failed; run: rclone config reconnect ${REMOTE%%:*}:"
}

upload() {
	local file=$1 dest=$REMOTE/$2
	"${RCLONE[@]}" copyto "$file" "$dest/$(basename "$file")" || fail "upload to $dest failed"
	"${RCLONE[@]}" delete "$dest" --min-age "$RETENTION" || log "WARN: prune $dest failed"
	"${RCLONE[@]}" rmdirs "$dest" --leave-root 2>/dev/null
	log "Uploaded $(basename "$file") -> $dest"
}

backup_secrets() {
	log "Backing up secrets"
	local out=$WORK/secrets-$STAMP.tar.gz
	# -C $HOME keeps paths relative; missing paths are warnings, not fatal
	tar --no-xattrs -czf "$out" -C "$HOME" \
		--exclude '.config/packer' --exclude '*/cache' --exclude '*/Cache' --exclude '*.sock' --exclude '.ssh/agent' --exclude '*/ipc' \
		Code/scripts/dotfiles/zshrc Documents/credentials .config .ssh .aws .local/share/atuin/key \
		|| log "WARN: tar reported errors (Full Disk Access for launchd?)"
	upload "$out" secrets
}

backup_pkg() {
	log "Backing up pkgs"
	local dir=$WORK/pkg-$STAMP
	mkdir "$dir"
	brew bundle dump --file="$dir/Brewfile" --force || log "WARN: brew bundle failed"
	command -v gem >/dev/null && gem list > "$dir/gem.txt"
	command -v npm >/dev/null && npm ls -g --depth=0 > "$dir/npm.txt" 2>/dev/null
	command -v pip3 >/dev/null && pip3 freeze > "$dir/pip.txt" 2>/dev/null
	tar -czf "$dir.tar.gz" -C "$WORK" "$(basename "$dir")"
	upload "$dir.tar.gz" pkg
}

wait_for_network
check_auth
case "${1:-all}" in
	secrets) backup_secrets ;;
	pkg) backup_pkg ;;
	all) backup_secrets; backup_pkg ;;
	*) fail "unknown target: $1" ;;
esac
log "Done"

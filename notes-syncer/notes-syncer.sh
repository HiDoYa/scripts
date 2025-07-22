#!/bin/bash

REMOTE_HOST="hiroya.gojo@172.18.1.7"
REMOTE_PATH="./Documents/Obsidian/Work/Sync/Transmit.md"
LOCAL_DIR="$OBSIDIAN_DIR/Sync"
TIMESTAMP=$(date +%s)
LOCAL_FILE="$LOCAL_DIR/transmit_${TIMESTAMP}.md"

scp "$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_FILE"
ssh "$REMOTE_HOST" "echo '' > $REMOTE_PATH"
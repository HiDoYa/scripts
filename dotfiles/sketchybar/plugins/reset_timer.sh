#!/usr/bin/env bash

pid=$(/bin/ps -A | grep -v 'grep' | grep .config/sketchybar/plugins/timer.py | cut -d ' ' -f 1)
kill ${pid}

sketchybar --set timer label=""

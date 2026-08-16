#!/usr/bin/env bash
# Cross-window agent-state badge for a catppuccin window tab.
# Arg: window_id. Scans panes in that window for the highest-priority
# tmux-agent-indicator state and prints a small colored dot for it.
set -euo pipefail

window_id="${1:-}"
[ -z "$window_id" ] && exit 0

tmux_get_env() {
    tmux show-environment -g "$1" 2>/dev/null | sed 's/^[^=]*=//' || true
}

rank() {
    case "$1" in
        needs-input) echo 3 ;;
        done) echo 2 ;;
        running) echo 1 ;;
        *) echo 0 ;;
    esac
}

best_state=""
best_rank=0

while IFS= read -r pane_id; do
    [ -z "$pane_id" ] && continue
    state=$(tmux_get_env "TMUX_AGENT_PANE_${pane_id}_STATE")
    [ -z "$state" ] && continue
    r=$(rank "$state")
    if [ "$r" -gt "$best_rank" ]; then
        best_rank=$r
        best_state="$state"
    fi
done < <(tmux list-panes -t "$window_id" -F '#{pane_id}' 2>/dev/null)

case "$best_state" in
    needs-input) printf '#[fg=colour226] ●#[fg=default,nobold]' ;;
    done)        printf '#[fg=colour196] ●#[fg=default,nobold]' ;;
    running)     printf '#[fg=colour250] ○#[fg=default,nobold]' ;;
esac

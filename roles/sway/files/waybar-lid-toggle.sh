#!/bin/bash
# Keep the laptop awake with the lid closed, toggled from waybar.
# Holds a logind "handle-lid-switch" inhibitor in a transient user unit, so no
# root is needed. The wanted state is stored in a file so it survives reboots:
# waybar calls "status" on startup, which re-creates the inhibitor if needed.
#   lid-toggle.sh          toggle (waybar on-click)
#   lid-toggle.sh status   sync inhibitor with saved state, print waybar JSON

unit=lid-inhibit
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/lid-inhibit"

active() { systemctl --user is-active --quiet "$unit.service"; }
wanted() { [ -f "$state_file" ]; }

start() {
    systemd-run --user --quiet --unit="$unit" \
        systemd-inhibit --what=handle-lid-switch --who="waybar" \
        --why="Stay awake with lid closed" --mode=block sleep infinity
}

if [ "$1" = status ]; then
    if wanted && ! active; then
        start
    elif ! wanted && active; then
        systemctl --user stop "$unit.service"
    fi
    if active; then
        echo '{"text":"LID off","class":"awake","tooltip":"Lid close is ignored (click to restore suspend)"}'
    else
        echo '{"text":"LID","class":"default","tooltip":"Lid close follows system default (click to stay awake)"}'
    fi
    exit 0
fi

mkdir -p "$(dirname "$state_file")"
if wanted; then
    rm -f "$state_file"
    systemctl --user stop "$unit.service"
    notify-send -a "Lid" "Lid close suspends again"
else
    touch "$state_file"
    start
    notify-send -a "Lid" "Staying awake with the lid closed"
fi
pkill -RTMIN+8 waybar

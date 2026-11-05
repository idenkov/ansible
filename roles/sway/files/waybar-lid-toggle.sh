#!/bin/bash
# Keep the laptop awake with the lid closed, toggled from waybar.
# Holds a logind "handle-lid-switch" inhibitor in a transient user unit, so no
# root is needed and it ends on logout or reboot.
#   lid-toggle.sh          toggle (waybar on-click)
#   lid-toggle.sh status   print waybar JSON

unit=lid-inhibit

active() { systemctl --user is-active --quiet "$unit.service"; }

if [ "$1" = status ]; then
    if active; then
        echo '{"text":"LID off","class":"awake","tooltip":"Lid close is ignored (click to restore suspend)"}'
    else
        echo '{"text":"LID","class":"default","tooltip":"Lid close follows system default (click to stay awake)"}'
    fi
    exit 0
fi

if active; then
    systemctl --user stop "$unit.service"
    notify-send -a "Lid" "Lid close suspends again"
else
    systemd-run --user --quiet --unit="$unit" \
        systemd-inhibit --what=handle-lid-switch --who="waybar" \
        --why="Stay awake with lid closed" --mode=block sleep infinity
    notify-send -a "Lid" "Staying awake with the lid closed"
fi
pkill -RTMIN+8 waybar

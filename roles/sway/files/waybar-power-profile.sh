#!/bin/bash
# Power profile for waybar; works on waybar versions without the native
# power-profiles-daemon module (e.g. 0.9.x on Ubuntu 24.04).
#   power-profile.sh          cycle performance -> balanced -> power-saver (on-click)
#   power-profile.sh status   print waybar JSON

cur=$(powerprofilesctl get 2>/dev/null) || exit 0

if [ "$1" = status ]; then
    case $cur in
        performance) label=PERF ;;
        balanced)    label=BAL ;;
        power-saver) label=SAVE ;;
        *)           label=$cur ;;
    esac
    printf '{"text":"%s","class":"%s","tooltip":"Power profile: %s (click to change)"}\n' "$label" "$cur" "$cur"
    exit 0
fi

case $cur in
    performance) next=balanced ;;
    balanced)    next=power-saver ;;
    *)           next=performance ;;
esac
powerprofilesctl set "$next" 2>/dev/null || {
    # Not every machine has a performance profile
    powerprofilesctl set balanced
}
pkill -RTMIN+9 waybar

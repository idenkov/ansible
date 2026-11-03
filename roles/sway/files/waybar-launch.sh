#!/bin/sh
# Start waybar only once sway has applied the multi-layout keyboard config.
#
# waybar 0.15.0's sway/language module builds its layout table once, from the
# first get_inputs reply. If that happens before sway applies `xkb_layout us,bg`,
# the table is incomplete and the language label stays blank until waybar
# restarts. Fixed on upstream master (table refreshed on input events), so
# this wrapper can go once a newer waybar is packaged.
i=0
while [ "$i" -lt 50 ]; do
    swaymsg -t get_inputs -r 2>/dev/null \
        | jq -e 'any(.[]; .type == "keyboard" and (.xkb_layout_names | length) > 1)' >/dev/null \
        && break
    i=$((i + 1))
    sleep 0.1
done
exec waybar "$@"

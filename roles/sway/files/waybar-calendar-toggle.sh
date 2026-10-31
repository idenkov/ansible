#!/bin/sh
# Clock on-click: open GNOME Calendar, or close it if it's already open.
if swaymsg -t get_tree | grep -q '"app_id": "org.gnome.Calendar"'; then
    swaymsg '[app_id="org.gnome.Calendar"] kill' >/dev/null
else
    setsid -f gnome-calendar >/dev/null 2>&1
fi

#!/bin/sh
# Clock on-click: toggle GNOME Calendar.
#
# Instead of killing the process when "closing" it, park it in the sway
# scratchpad. gnome-calendar is slow to open because each cold start has to
# spin up a fresh GtkApplication and re-subscribe to evolution-data-server's
# calendar views before it can render anything. Keeping the process alive
# (just hidden) means reopening is an instant scratchpad show instead of a
# full restart.
in_scratchpad() {
    swaymsg -t get_tree | jq -e '.. | objects | select(.name == "__i3_scratch") | .. | objects | select(.app_id? == "org.gnome.Calendar")' >/dev/null 2>&1
}

tree=$(swaymsg -t get_tree)

if echo "$tree" | jq -e '.. | objects | select(.name == "__i3_scratch") | .. | objects | select(.app_id? == "org.gnome.Calendar")' >/dev/null 2>&1; then
    # `scratchpad show` on this sway version occasionally reports success
    # without actually unhiding the window; retry a few times rather than
    # leave the user clicking into nothing.
    i=0
    while [ "$i" -lt 5 ] && in_scratchpad; do
        swaymsg '[app_id="org.gnome.Calendar"] scratchpad show' >/dev/null
        sleep 0.1
        i=$((i + 1))
    done
elif echo "$tree" | jq -e '.. | objects | select(.app_id? == "org.gnome.Calendar")' >/dev/null 2>&1; then
    swaymsg '[app_id="org.gnome.Calendar"] move to scratchpad' >/dev/null
else
    setsid -f gnome-calendar >/dev/null 2>&1
fi

#!/bin/bash
# Network module on-click: pick a Wi-Fi network in fuzzel and connect with nmcli.
# Replaces nm-applet's tray menu, which waybar closes or moves to the left edge
# whenever a scan result arrives and nm-applet rebuilds the list.

notify() { notify-send -a "Wi-Fi" "$@"; }

# Waybar clicks move focus off fuzzel when the mouse leaves the bar; without
# --no-exit-on-keyboard-focus-loss fuzzel closes as soon as the mouse moves.
# Toggle: a second click while the menu is open closes it
if pkill -f '^fuzzel --dmenu .*--prompt=Wi-Fi: '; then
    exit 0
fi

# Open instantly with the cached scan ("--rescan auto" blocks ~8s when the last
# scan is over 30s old) and refresh in the background for next time.
# "Rescan" in the menu waits for a fresh scan.
nmcli dev wifi rescan >/dev/null 2>&1 &
rescan=no
while :; do
    # SSID last and --escape no, so colons inside an SSID don't break the split.
    # One entry per SSID (strongest access point), connected network first.
    mapfile -t rows < <(
        nmcli --escape no -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan "$rescan" |
        awk -F: '{
            inuse = $1; signal = $2; sec = $3
            ssid = substr($0, length($1 $2 $3) + 4)
            if (ssid !~ /[^[:space:][:cntrl:]]/) next
            if (!(ssid in best) || signal > best[ssid]) { best[ssid] = signal; security[ssid] = sec }
            if (inuse == "*") active[ssid] = 1
        }
        END {
            for (s in best)
                printf "%d\037%03d\037%s\037%s\n", (s in active) ? 1 : 0, best[s], security[s], s
        }' | sort -t$'\037' -k1,1nr -k2,2nr
    )

    entries=("Rescan")
    ssids=("")
    secs=("")
    for row in "${rows[@]}"; do
        IFS=$'\037' read -r active signal sec ssid <<<"$row"
        mark="  "; [ "$active" = 1 ] && mark="* "
        lock=""; [ -n "$sec" ] && [ "$sec" != "--" ] && lock="  [locked]"
        entries+=("$(printf '%s%-32s %3d%%%s' "$mark" "$ssid" "$((10#$signal))" "$lock")")
        ssids+=("$ssid")
        secs+=("$sec")
    done

    idx=$(printf '%s\n' "${entries[@]}" |
        fuzzel --dmenu --index --no-exit-on-keyboard-focus-loss --prompt="Wi-Fi: " --width=50 --lines=12) || exit 0

    if [ "$idx" = 0 ]; then
        rescan=yes
        continue
    fi
    break
done

ssid=${ssids[$idx]}
sec=${secs[$idx]}

# Saved profile for this SSID? Bring it up instead of creating a duplicate.
saved=""
while IFS=: read -r type name; do
    [ "$type" = 802-11-wireless ] || continue
    if [ "$(nmcli -g 802-11-wireless.ssid con show id "$name" 2>/dev/null)" = "$ssid" ]; then
        saved=$name
        break
    fi
done < <(nmcli --escape no -t -f TYPE,NAME con show)

if [ -n "$saved" ]; then
    notify "Connecting to $ssid…"
    if out=$(nmcli con up id "$saved" 2>&1); then
        notify "Connected to $ssid"
        exit 0
    fi
    # Saved password may be stale; fall through and ask for a new one
    case $out in
        *[Ss]ecret*|*[Pp]assword*|*authentication*) ;;
        *) notify -u critical "Could not connect to $ssid" "$out"; exit 1 ;;
    esac
    nmcli con delete id "$saved" >/dev/null 2>&1
fi

if [ -z "$sec" ] || [ "$sec" = "--" ]; then
    notify "Connecting to $ssid…"
    if out=$(nmcli dev wifi connect "$ssid" 2>&1); then
        notify "Connected to $ssid"
    else
        notify -u critical "Could not connect to $ssid" "$out"
        exit 1
    fi
    exit 0
fi

pass=$(fuzzel --dmenu --no-exit-on-keyboard-focus-loss --prompt-only="Password for $ssid: " --password --width=50) || exit 0
[ -n "$pass" ] || exit 0

notify "Connecting to $ssid…"
if out=$(nmcli dev wifi connect "$ssid" password "$pass" 2>&1); then
    notify "Connected to $ssid"
else
    # Don't keep a profile with a wrong password around
    nmcli con delete id "$ssid" >/dev/null 2>&1
    notify -u critical "Could not connect to $ssid" "$out"
    exit 1
fi

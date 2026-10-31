#!/bin/sh
# gnome-control-center exits unless XDG_CURRENT_DESKTOP is GNOME/Unity.
# Pretend to be GNOME for this process only, so it opens from sway too.
# Deployed by ansible (roles/sway) to ~/.local/bin, ahead of /usr/bin in PATH.
XDG_CURRENT_DESKTOP=GNOME exec /usr/bin/gnome-control-center "$@"

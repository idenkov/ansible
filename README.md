Run `bash init.sh`

Playbooks:

- `laptop-role.yml` — `base` + `sway` (Wayland). Ubuntu 24.04 / 26.04.
- `desktop.yml` — `base` + `i3` (X11) + `desktop` + `docker`.
- `server.yml` — blackbox.

Laptop: `ansible-playbook laptop-role.yml -K -b`, then log out and pick "Sway" in the GDM session menu (gear icon).

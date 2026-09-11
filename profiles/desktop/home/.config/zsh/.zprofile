# ~/.config/zsh/.zprofile — desktop profile only (zotac, razer; absent on
# mini). Runs for login shells before the interactive .zshrc. phiOS has no
# display manager (Sec662 — agetty on a VT is the login screen), so the
# TTY1 console login simply execs this machine's Hyprland session; quitting
# the session (logout) returns you to getty. `start-hyprland` is the
# hyprland package's own wrapper — importing the shell environment and
# starting the systemd-integrated session, portals included — which is why
# the install procedures call it instead of the bare binary. Everything else
# the session needs follows on its own once the compositor exists:
# hyprland.lua's start hook brings up phi-shell, hyprsunset and btop, and
# pipewire/wireplumber are persistent user units.
[[ $(tty) == /dev/tty1 && -z ${WAYLAND_DISPLAY:-} ]] && exec start-hyprland
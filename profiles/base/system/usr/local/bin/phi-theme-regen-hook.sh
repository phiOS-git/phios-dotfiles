#!/bin/sh
# phiOS — pacman hook helper (S-45). /etc-material, never applied by
# phios-install — install to /usr/local/bin/, chmod +x, after reading it.
# Called by phi-theme-regen.hook as root, PostTransaction. Its whole job:
# find the logged-in graphical user (a hook has no session of its own —
# root has no meaningful $HOME, $XDG_STATE_HOME, or phios-dotfiles
# checkout) and re-run `phi theme set` AS that user, so the regenerated
# files land in their home with their own environment, not root's.
#
# `loginctl list-sessions` + `loginctl show-session ... -p Type -p Name`
# real, documented systemd-logind commands — filters for a "seat0" session
# whose Type is not "tty" (i.e. a graphical one), first match. Multiple
# concurrent graphical sessions (fast user switching) are NOT handled —
# unverified against real hardware, flagged for cheap veto; this project's
# own hosts are single-user desktops, so this is expected to be moot in
# practice, not verified to BE moot.
set -eu

user=""
for session in $(loginctl list-sessions --no-legend | awk '{print $1}'); do
    type=$(loginctl show-session "$session" -p Type --value 2>/dev/null || true)
    case "$type" in
        wayland|x11)
            user=$(loginctl show-session "$session" -p Name --value 2>/dev/null || true)
            [ -n "$user" ] && break
            ;;
    esac
done

if [ -z "$user" ]; then
    echo "phi-theme-regen-hook: no graphical session found, skipping" >&2
    exit 0
fi

# DefaultVariant fallback duplicated from phi/internal/theme/variant.go's
# own CurrentVariant() — that Go function is not reachable from a shell
# script, so this is the shell-side equivalent of the same default, not an
# independent decision.
variant=$(runuser -u "$user" -- phi state get theme.variant 2>/dev/null || true)
[ -z "$variant" ] && variant="dark"

runuser -u "$user" -- phi theme set "$variant"

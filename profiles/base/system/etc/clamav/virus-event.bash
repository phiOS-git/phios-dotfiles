#!/bin/bash
# phiOS — clamd.conf's VirusEvent target (out-of-plan: clamav). Runs as the
# `clamav` system user, once per detection, with CLAM_VIRUSEVENT_* set in
# its environment (clamd's own contract — see clamd.conf(5)). Installed
# 0755 root:root; needs profiles/base/system/etc/sudoers.d/clamav for the
# notify-send call below to actually reach a user's session non-
# interactively.
#
# Loops every logged-in graphical session rather than assuming one: any of
# the three hosts can have more than one, and `mini` (headless, no
# graphical session ever) will simply find none here — the loop runs zero
# times, a harmless no-op, not an error.
PATH=/usr/bin
ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"

# Send an alert to all graphical users.
for ADDRESS in /run/user/*; do
    USERID=${ADDRESS#/run/user/}
    /usr/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" PATH=${PATH} \
        /usr/bin/notify-send -u critical -i dialog-warning "Virus found!" "$ALERT"
done

# razer-hw — /etc material

Empty on purpose, as of S-46.

The step card (`docs/phios-agent-brief.md`, S-46) called for a
`/etc/udev/hwdb.d/` rule mapping the volume/brightness keys' raw codes to
`KEYBOARD_KEY_<code>=volumeup|...`, built from the codes S-06 captured. That
premise turned out to be wrong: S-06's own diagnosis (`PROGRESS.md`, S-06
row) found the kernel already reports **standard, correctly-named** HID
scancodes for every one of those keys — `KEY_MUTE`, `KEY_VOLUMEUP`,
`KEY_VOLUMEDOWN`, `KEY_BRIGHTNESSUP`, `KEY_BRIGHTNESSDOWN` — with no
hwdb-level remapping needed at all. The real gap was one layer up: no
Hyprland keybinding existed for any of them. S-46 fixed that instead
(`profiles/desktop/home/.config/hypr/hyprland.lua`, the `XF86Audio*` /
`XF86MonBrightness*` binds).

`Fn+F4` is the one exception S-06 found, and it is not a keycode gap
either: the keyboard's own firmware synthesizes the literal Windows
shortcut Super+P (Right-GUI held + P). No hwdb rule can change what a
firmware-level HID report already is. What Super+P (or Fn+F4) SHOULD do on
phiOS is an open question, not answered here — phiOS has no
display-projection concept yet, and no existing bind claims Super+P.
Noted, not guessed at.

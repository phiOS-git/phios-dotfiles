# workstation

`zotac`. The counterpart of `laptop`: a machine that is always on mains, has no
battery, no backlight and no touchpad, and drives external monitors.

No `packages.txt` yet. Everything package-level it will eventually hold — the
monitor layout of ADR 077, the "no power saving" defaults — is owned by the
settings panel and by profiles that do not exist yet. It is declared in
`hosts/zotac.txt` from S-03 so that the place exists before something needs
it, which is cheaper than discovering the gap later.

`system/` (S-05) carries what is `zotac`-specific and neither GPU-driver nor
gaming-stack material: the `zram` generator and its `sysctl` companion, and
the shape of the two-disk `crypttab` (root via `crypttab.initramfs`, the
`bulk` data disk cascading after it). **None of this is applied by the
installer** — `phios-install --system-diff` only shows the difference against
the machine; applying a file is a manual, `sudo`, file-by-file action. UUIDs
are machine data and are never written here — the crypttab entries carry
`<system-partition-uuid>` and `<bulk-partition-uuid>` placeholders, which will
show as a permanent, expected difference in `--system-diff`.

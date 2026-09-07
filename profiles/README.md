# profiles/

One directory per profile. A host is configured by listing profiles in
`hosts/<host>.txt`; the order there is significant, because a profile that
provides a concrete provider must precede one that requires it.

```
<name>/
├── packages.txt          pacman packages, T0 repositories only
├── services-user.txt     systemd --user units to enable — declared, never enabled here
├── services-system.txt   system units to enable — declared, never enabled here
├── home/                 tree linked into $HOME with relative symlinks
├── templates/            *.tmpl rendered into $HOME against design/
└── system/               /etc material: shown by --system-diff, never applied
```

Every part is optional: a profile with only a `packages.txt` is valid.

Empty until **S-03**, which moves the pre-M0 `modules/` tree here without
changing a single byte of what lands on either machine. The planned set is in
the master plan §5.3: `base`, `desktop`, `laptop`, `workstation`, `nvidia`,
`intel-gpu`, `razer-hw`, `gaming`, `study`, `server`.

While this directory is empty, `bin/phios-install` reports "no profiles
declared" and exits cleanly — the host files still name the old modules, and
that is the expected transitional state, not drift.

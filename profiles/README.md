# profiles/

One directory per profile. A host is configured by listing profiles in
`hosts/<host>.txt`; the order there is significant, because a profile that
provides a concrete provider must precede one that requires it.

```
<name>/
├── packages.txt          pacman packages, T0 repositories only
├── services-user.txt     systemd --user units to enable — declared, never enabled here
├── services-system.txt   system units to enable — declared, never enabled here
├── manual.txt            one-off commands the installer cannot run — declared, never run here
├── home/                 tree linked into $HOME with relative symlinks
├── templates/            *.tmpl rendered into $HOME against design/
└── system/               /etc material: shown by --system-diff, never applied
```

Every part is optional: a profile with only a `packages.txt` is valid, and so
is a profile with nothing at all.

The three list files are all the same contract — the installer states what has
to happen and performs none of it. `manual.txt` is the catch-all for what is
neither a package, nor a file, nor a unit; the yazi git plugin is the first
entry and the reason the file exists (master plan C-10).

## The set

| Profile | Hosts | Contents |
|---|---|---|
| `base` | all | Shell, CLI tools, fonts, editor, file manager. No graphical dependency |
| `desktop` | `zotac`, `razer` | Compositor, portals, audio, terminal, browser, media |
| `laptop` | `razer` | Power, brightness, hibernation, touchpad |
| `workstation` | `zotac` | No power saving, external monitors. Empty |
| `nvidia` | `zotac` | Driver and 32-bit libraries |
| `intel-gpu` | `razer` | Mesa Vulkan and its 32-bit library |
| `razer-hw` | `razer` | `openrazer-daemon` and the headers its DKMS module builds against |
| `gaming` | `zotac`, `razer` | Steam and the 32-bit Vulkan loader |
| `study` | `razer` | Reading, bibliography, spaced repetition, office. Empty until M6 |
| `server` | `mini` | Services, nothing graphical. Empty until M6 |

`workstation`, `study` and `server` carry only a `README.md` explaining why
they are empty. They are declared in the host files from S-03 so the place
exists before something needs it.

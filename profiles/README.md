# profiles/

One directory per profile. A host is configured by listing profiles in
`hosts/<host>.txt`; the order there is significant, because a profile that
provides a concrete provider must precede one that requires it.

```
<name>/
├── packages.txt          pacman packages, T0 (and T1, the [phi] repo) only
├── external.txt          non-official software: tier TC, T2, T3 or T4 — see below
├── services-user.txt     systemd --user units to enable — declared, never enabled here
├── services-system.txt   system units to enable — declared, never enabled here
├── manual.txt            one-off commands the installer cannot run — declared, never run here
├── home/                 tree linked into $HOME with relative symlinks
├── templates/            *.tmpl rendered into $HOME against design/
└── system/               /etc material: shown by --system-diff, never applied
```

Every part is optional: a profile with only a `packages.txt` is valid, and so
is a profile with nothing at all.

The four list files below `packages.txt` are all the same contract — the
installer states what has to happen and performs none of it. `manual.txt` is
the catch-all for what is neither a package, nor a file, nor a unit; the yazi
git plugin is its first entry.

## `external.txt`

The tier ladder (rule 1 in the workspace `AGENTS.md`) has six tiers; only four
of them are declared here. `T0` (official Arch) and `T1` (the private `[phi]`
repo) stay in `packages.txt` — a `[phi]` package already comes from a
configured pacman repository, so pacman already installs, tracks and removes
it, and a second declaration path here would be a mistake, not a convenience.
`external.txt` is where `TC`, `T2`, `T3` and `T4` are declared: the tier, the
pin and the reason, together, so a yearly prune is possible.

One record per line, six fields separated by `|`:

```
name | tier | source | ref | sha256 | reason
```

- Each field is trimmed of surrounding whitespace.
- `#` starts a comment anywhere on a line, exactly like every other list file
  here (`phios_read_list` strips it before the fields are split) — so a `#`
  may **never** appear inside a field.
- Blank lines are ignored.
- A line that does not split into exactly six fields is an error.

**Field rules.** These are normative for every parser that reads this file —
`bin/lib/external.sh` here, and the `phi` CLI's Go parser, built against this
same spec. What a parser's error message says is not part of the contract;
which lines it accepts or rejects is, and the two must agree exactly.

- **`name`** must match `^[A-Za-z0-9._-]+$`. It becomes a generated filename
  (a `.desktop` entry, see below) and, later, a `~/.local/bin` entry, so
  anything outside that character set is a path-traversal vector from
  repository content, not just untidy.
- **`tier`** is one of `TC`, `T2`, `T3`, `T4`. `T0` or `T1` here is an error —
  they belong in `packages.txt`. Any other value is an unknown tier.
- **`source`** must be non-empty.
- **`ref`** must be non-empty and never the literal `latest` (an exact,
  case-sensitive match) — tags and `latest` move, and a pin must not. For
  tier `TC` it must also start with `sha256:`: a container is pinned by image
  digest, never by tag.
- **`sha256`** depends on the tier:
  - `T4` — exactly 64 lowercase hex characters.
  - `T3` — `-`, or 64 lowercase hex characters.
  - `T2` and `TC` — exactly `-`. Flatpak and the container registry provide
    their own integrity; a second, hand-copied checksum here would only rot.
- **`reason`** must be non-empty. It is load-bearing: it is what makes a
  yearly prune possible.

Example:

```
wivrn | T2 | flathub:io.github.wivrn.wivrn | 0.22 | - | VR streaming, no official package
foo   | T4 | https://example.org/foo.AppImage | 3.1.2 | <64 lowercase hex characters> | required by a course, no alternative
```

**What the installer does with this file.** `bin/lib/external.sh` only parses
and reports it — in `--dry-run` and `--check`, and as drift when a record is
malformed. It never fetches or installs anything: downloading and running an
arbitrary artifact from the installer is the exact risk the tier ladder exists
to bound. The declaration is the record; the user installs. The one thing the
installer generates from a declaration is a `.desktop` entry for each `T4`
entry, so a correctly-installed AppImage is actually launchable — see
`bin/lib/plan.sh` for why that generation has to live in the installer rather
than in `phi`. Whether a declared entry is actually present, up to date or
tampered with on the machine is `phi pkg audit`'s job, in the Go CLI, not
this installer's.

**Per-host scope.** `mini` carries an `external.txt` too, holding only `TC`
entries: rootless containers are the one non-pacman population on that host,
so leaving them undeclared would put the single thing that needs monitoring
outside the monitoring. Every other host's `external.txt` may also carry
`T2`, `T3` and `T4` entries; `mini` never does, because it is `T0`, `T1` and
`TC` only (rule 1).

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
| `study` | `razer` | Reading, bibliography, spaced repetition, office. Empty. |
| `server` | `mini` | Services, nothing graphical. Empty. |

`workstation`, `study` and `server` carry only a `README.md` explaining why
they are empty. They are declared in the host files so the place exists
before something needs it.

# phios-dotfiles

Configuration only, for a personal Arch Linux system spread across three hosts:
`zotac` (desktop, NVIDIA), `razer` (laptop, primary machine), `mini` (headless
server, 4 GB RAM). This repository holds package lists, symlink targets, and
templates. It contains no compiled code and no application source — those live
in the sibling repositories `phi`, `phi-shell`, and `phi-packages`.

The full plan this repository executes is in `docs/phios-master-plan.md`
(the single source of truth) and `docs/phios-agent-brief.md` (the step-by-step
backlog). `PROGRESS.md` tracks which step is done, in flight, or blocked.

## Current state

M0 is in progress, and two installers deliberately live side by side until it
finishes. Nothing here should be read as final.

```
install.sh           pre-M0 installer: reads hosts/$(hostname).txt, applies each
                     module in order. This is the one that has actually been run
                     on zotac and razer, and it stays the live one until S-03
modules/<name>/      pre-M0 content: packages.txt, files to symlink, *.tmpl
theme.sh             the nine colour values every *.tmpl currently renders against

bin/phios-install    v2 installer (S-01): idempotent, previewable, reversible,
                     and aware of what it created on this machine
bin/lib/             shared bash functions
design/              every colour, font, size, radius and motion value (S-02)
hosts/<name>.txt     ordered list of profiles for that host
profiles/<name>/     packages, home tree, templates, /etc material, services (S-03)
docs/adr/            decisions local to this repository, if any
```

`bin/phios-install` is **inert** as it stands: `profiles/` is empty, so it
reports "no profiles declared" and exits without touching anything. The host
files still name the pre-M0 modules. S-03 migrates them, and only then does
the v2 installer replace `install.sh`.

## What `install.sh` does today

For each module listed in `hosts/<host>.txt`, in order:

1. Installs `modules/<name>/packages.txt` with `pacman -S --needed`, if the
   file is non-empty.
2. Symlinks every plain file in the module into the matching path under
   `$HOME`.
3. Renders every `*.tmpl` file with `envsubst`, sourcing `theme.sh` for the
   substitution values, and writes the result into `$HOME`.

Module order in each host file is significant: a profile that provides a
concrete driver must precede one that requires it.

## What `bin/phios-install` will do

The machines are already configured, so the first real run of the v2 installer
is an update, not an installation. That shapes all four of its modes:

```
--dry-run       lists every file that would change and every package that would
                be installed, and changes nothing
--check         reports drift between repository and machine; exits 1 if any
--system-diff   shows profiles/*/system/ against the machine, read-only and
                unprivileged; nothing is ever applied
(default)       applies packages, symlinks and rendered templates, reconciles
                against the state manifest, and prints the systemd units to
                enable — without enabling them
```

Two behaviours are worth stating explicitly:

- **It removes what it no longer declares.** Every path it creates is recorded
  in `$XDG_STATE_HOME/phios/manifest`, with the source that produced it. On the
  next run, a path that has left the repository is removed from `$HOME` — unless
  it has been edited by hand since, in which case it is left alone and reported.
- **It moves aside anything it is about to overwrite** that it did not itself
  write, into `$XDG_STATE_HOME/phios/backup/<timestamp>/`, so a run can be
  undone.

Templates are rendered with `envsubst` restricted to the `PHI_*` names the
design tokens export, so a `$PATH` or `$HOME` written inside a configuration
file survives untouched.

## What this repository deliberately does not do

- **No `/etc` material, applied or otherwise, yet.** `/etc` changes are a
  strictly `[USER]` action, made with `sudo`, file by file — never something
  this installer runs. `M0` will add `profiles/*/system/` as a place to keep
  that material versioned and diffable; it stays unapplied by design (`I-09`).
- **No `systemctl`.** This installer places files; it never enables, starts,
  or restarts a service. Which units to enable is left as output for the user
  to act on.
- **No package installation for phiOS's own software.** `phi`, `phi-shell`,
  and every other in-house package are distributed through the `[phi]` pacman
  repository built in `M1` (`phi-packages`), not through this repository, and
  not before `M1` exists.
- **No service drift detection.** Profiles declare their systemd units and the
  installer prints them, but it never queries systemd and never enables
  anything, so `--check` says nothing about whether a unit is actually enabled.
  Enabling is a user action, and closing the reporting gap belongs with the
  `/etc` work at `S-05`.
- **No `theme.sh` fallback in the v2 installer.** Rendering a template without
  `design/` present is a hard error, not a half-render against the old nine
  values. That is deliberate: it keeps `I-05` enforceable.

## Documentation

`docs/` in this repository holds an offline copy of the four planning
documents this project runs on, so they travel with a clone even without
network access to the docs' canonical location:

- `phios-master-plan.md` — the SSOT: rules, decisions, milestones, registries.
- `phios-agent-brief.md` — the agent's operating contract and main-line backlog.
- `phios-agent-parallel.md` — tracks developable independently of machine state.
- `phios-user-runbook.md` — operations reserved to the user: packages, `/etc`,
  systemd, hardware diagnostics, the feedback protocol.

These are copies for reference. The canonical versions are wherever the user
keeps the planning repository; in case of any discrepancy, the master plan's
own precedence rule applies — `phios-master-plan.md` wins.

# phios-dotfiles

Configuration only, for a personal Arch Linux system spread across three hosts:
`zotac` (desktop, NVIDIA), `razer` (laptop, primary machine), `mini` (headless
server, 4 GB RAM). This repository holds package lists, symlink targets, and
templates. It contains no compiled code and no application source — those live
in the sibling repositories `phi`, `phi-shell`, and `phi-packages`.

The full plan this repository executes is in `docs/phios-master-plan.md`
(the single source of truth) and `docs/phios-agent-brief.md` (the step-by-step
backlog). `PROGRESS.md` tracks which step is done, in flight, or blocked.

## Layout

```
bin/phios-install    the one entry point: idempotent, previewable, reversible,
                     and aware of what it created on this machine
bin/phios-render     renders one template against the tokens
bin/lib/             shared bash functions
design/              every colour, font, size, radius and motion value
hosts/<name>.txt     ordered list of profiles for that host
profiles/<name>/     packages, home tree, templates, /etc material, services
docs/adr/            decisions local to this repository, if any
```

M0 is still in progress and nothing here should be read as final. The pre-M0
`install.sh`, `theme.sh` and `modules/` tree were removed at S-03, which moved
their content into `profiles/` without changing a byte of what is rendered onto
either machine; they are in the git history if a comparison is ever needed.

## What `bin/phios-install` does

For the profiles listed in `hosts/<host>.txt`, in order: installs their
packages, links their `home/` trees into `$HOME`, renders their `templates/`
against `design/`, and reconciles the result against a state manifest. The
machines are already configured, so the first real run is an update, not an
installation. That shapes all four modes:

```
--dry-run       lists every file that would change and every package that would
                be installed, and changes nothing
--check         reports drift between repository and machine; exits 1 if any
--system-diff   shows profiles/*/system/ against the machine, read-only and
                unprivileged; nothing is ever applied
(default)       applies packages, symlinks and rendered templates, reconciles
                against the state manifest, and prints the systemd units and
                manual steps to perform — without performing them
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

Profile order in each host file is significant: a profile that provides a
concrete driver must precede one that requires it.

## What this repository deliberately does not do

- **No `/etc` material, applied or otherwise.** `/etc` changes are a strictly
  `[USER]` action, made with `sudo`, file by file — never something this
  installer runs. `profiles/*/system/` is where that material is kept versioned
  and diffable; it stays unapplied by design (`I-09`). It is populated at S-05
  and is empty until then.
- **No `systemctl`.** This installer places files; it never enables, starts,
  or restarts a service. Which units to enable is left as output for the user
  to act on.
- **No package installation for phiOS's own software.** `phi`, `phi-shell`,
  and every other in-house package are distributed through the `[phi]` pacman
  repository built in `M1` (`phi-packages`), not through this repository, and
  not before `M1` exists.
- **No verification of what it only declares.** Profiles declare systemd units
  in `services-*.txt` and one-off commands in `manual.txt`; the installer prints
  both and never queries systemd, never runs the commands, and never checks
  whether either has been done. So `--check` says nothing about them, and a
  clean `--check` is not evidence that the session is complete. Closing that
  reporting gap belongs with the `/etc` work at `S-05`.
- **No fallback palette.** Rendering a template when `design/` is missing or
  the variant is unknown is a hard error, not a half-render against defaults.
  That is deliberate: it keeps `I-05` enforceable.

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

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

This is the **pre-M0** layout: a minimal installer that already works on
`zotac` and `razer`, and that M0 (`phios-agent-brief.md`, steps S-01 through
S-06) will rebuild into a structured, idempotent, previewable one — without
changing what lands on either machine. Nothing here should be read as final.

```
hosts/<name>.txt     ordered list of modules to install for that host
modules/<name>/      packages.txt, plain files to symlink, *.tmpl files to render
install.sh           reads hosts/$(hostname).txt, applies each module in order
theme.sh             the nine colour values every *.tmpl currently renders against
```

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
- **No drift detection or safe removal.** The current installer only adds; it
  has no state manifest and cannot tell you what it created versus what
  changed underneath it, and it cannot remove a file whose source disappeared
  from the repo. Closing this is `S-01` (`C-10` in the master plan).
- **No dry run.** Every current invocation is destructive-by-default in the
  sense that it applies immediately; there is no `--dry-run` or `--check` yet.

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

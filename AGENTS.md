# phios-dotfiles — configuration

**Configuration only.** No compiled code, no application source. Package
lists, symlink targets, templates, `/etc` material (kept, never applied),
design tokens, and one install engine.

Part of the phiOS workspace. The workspace `AGENTS.md` (one level up, or in
`docs/archive/` of a standalone clone) carries the rules for every
repository — **branch locally, only `main`/`dev` on the remote; only
official Arch packages; the machines are off-limits; no secrets in a public
repo; design tokens are the only source of colour, font and size.** Not
repeated here.

Canonical branch is **`main`** (renamed from `master`).

When your work matches an entry in the workspace's `docs/TODO.md`, claim it
with `[taken]` and report the result in `docs/VERIFICATION.md` — see *The
TODO / VERIFICATION loop* in the workspace `AGENTS.md`.

## How this repo is built

- **`bin/phios-install`** is the one entry point, with four modes:
  `--dry-run` (list changes, touch nothing), `--check` (report drift,
  exit 1 if any), `--system-diff` (show `profiles/*/system/` against live
  `/etc`, read-only, unprivileged), and default (apply packages, symlinks,
  rendered templates; reconcile against the state manifest). The machines
  are already configured — the first real run is an update, not an install.
- **Idempotent and reversible.** Every path it creates is recorded in
  `$XDG_STATE_HOME/phios/manifest` with its source; a path that leaves the
  repo is removed from `$HOME` next run unless hand-edited since. Anything
  it would overwrite that it did not write is backed up under
  `$XDG_STATE_HOME/phios/backup/<timestamp>/`.
- **`design/`** is the single source of every colour, font, size, radius
  and motion value. Nothing anywhere may contain such a literal. Rendering
  a template with `design/` missing or the variant unknown is a hard error,
  never a half-render.
- **`profiles/<name>/`**: `packages.txt`, a `home/` tree symlinked
  wholesale into `$HOME`, `templates/` rendered against `design/` (via
  `envsubst` restricted to `PHI_*`), `system/` (`/etc` material),
  `services-*.txt`, `manual.txt`. Composed per host in `hosts/<host>.txt`.
- **`hosts/<host>.txt` order is significant** — a profile providing a
  concrete provider must precede one requiring it. The regression that
  actually happened: `gaming` before the GPU profile made pacman prompt
  for `vulkan-driver`.
- Bootstrap scripts are bash and may depend only on coreutils, bash, git
  and gettext — they run on a fresh machine, before `phi` exists.

## The boundaries this repo does not cross

- **No `/etc` writes.** `profiles/*/system/` holds that material versioned
  and diffable; `--system-diff` shows it; applying a file is a `[USER]`
  action, with `sudo`, file by file.
- **No `systemctl`.** `services-*.txt` *declares* units; the installer
  prints them and never enables, starts or checks one. A clean `--check`
  is not evidence the session is complete.
- **No install of phiOS's own packages.** `phi`, `phi-shell`, … come
  through the `[phi]` pacman repo, listed in a profile's `packages.txt`.
- **No secrets, no addresses.** The `[phi]` mirror file
  (`profiles/base/system/etc/pacman.d/phi-mirrorlist`) ships placeholder
  `Server =` / `<port>`; nothing fills them in. Notification topics, keys,
  overlay hostnames never appear.

## Where the live checkout is

Every install procedure clones this to `~/phios-dotfiles`, and `phi`
resolves it as `$PHI_DOTFILES` else `~/phios-dotfiles`. The current machine
keeps it at `~/.local/share/phios/dotfiles`; `bin/phios-install` writes the
real path to `~/.config/phios/dotfiles-root` and
`~/.config/environment.d/10-phios.conf` on every run so `$PHI_DOTFILES`
resolves regardless.

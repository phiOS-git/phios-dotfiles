# phios-dotfiles — configuration

**Configuration only.** No compiled code, no application source. Package
lists, symlink targets, templates, `/etc` material (kept, never applied),
design tokens, and one install engine.

The workspace `AGENTS.md` one level up carries the rules for every repository
and is not repeated here.

## How this repo is built

- **`bin/phios-install`** is the one entry point, with four modes:
  `--dry-run` (list every change, touch nothing), `--check` (report drift,
  exit 1 if any), `--system-diff` (show `profiles/*/system/` against the live
  `/etc`, read-only and unprivileged), and the default (apply packages,
  symlinks and rendered templates, reconciling against the state manifest).
  The machines are already configured, so a real run is an update, not an
  install.
- **Idempotent and reversible.** Every path it creates is recorded in
  `$XDG_STATE_HOME/phios/manifest` with its source. A path that leaves the
  repo is removed from `$HOME` on the next run unless it was hand-edited
  since, in which case it is left and reported. Anything it would overwrite
  that it did not write is backed up under
  `$XDG_STATE_HOME/phios/backup/<timestamp>/`.
- Shared bash under `bin/lib/` (`plan`, `profiles`, `packages`, `external`,
  `manifest`, `system`, `tokens`, `env`, `common`). Bootstrap may depend only on
  coreutils, bash, git and gettext — it runs on a fresh machine, before `phi`
  exists.
- It writes `~/.config/phios/dotfiles-root` and
  `~/.config/environment.d/10-phios.conf` on every run, so `$PHI_DOTFILES`
  resolves for both the login shell and the systemd user environment wherever
  the checkout lives.
- **`bin/phios-capabilities`** probes `/sys` and `/proc` only — no `lspci`,
  no `udevadm` — for GPU vendor, backlight, battery, wifi, bluetooth,
  touchpad, touchscreen, ambient-light sensor and Chroma.
- **`bin/phios-render`** renders one template standalone; it is the comparison
  target for `phi theme render`.

## Profiles and hosts

Profiles are `base`, `desktop`, `laptop`, `intel-gpu`, `nvidia`, `razer-hw`,
`gaming`, `workstation`, `study`, `server`, composed per host in
`hosts/<host>.txt`:

- `zotac` — base, desktop, workstation, nvidia, gaming
- `razer` — base, desktop, laptop, intel-gpu, razer-hw, gaming, study
- `mini` — base, server

**Order is significant.** A profile providing a concrete implementation must
precede one that only requires it — putting `gaming` before the GPU profile
made pacman prompt interactively for `vulkan-driver`, which actually happened
on `razer`.

Each profile carries `packages.txt`, a `home/` tree symlinked wholesale into
`$HOME`, `templates/` rendered against `design/` (via `envsubst` restricted to
the `PHI_*` names, so a `$PATH` or `$HOME` inside a config file survives),
`system/` (`/etc` material), `services-*.txt` and `manual.txt`.

## Design tokens

`design/tokens.common.sh` plus `tokens.{dark,light}.sh` are the single source
of every colour, font, size, radius and motion value. `design/adapters.txt`
lists one row per themed target — template, destination, reload command,
reload class — and is what `phi theme set` consumes. `design/brand/` holds the
Φ SVGs, the ASCII mark and the PNG render script.

A row's reload column is `-` when the target genuinely has no reload path, or
`[unknown]` when one exists but is not wired. `[unknown]` is deliberate and
must not be guessed at: a wrong reload command fails silently — the file is
written, the application keeps its old colours, and nothing reports it.

Rendering with `design/` missing or the variant unknown is a hard error, never
a half-render.

## The boundaries this repo does not cross

- **No `/etc` writes.** `profiles/*/system/` holds that material versioned and
  diffable and `--system-diff` shows it; applying a file is the user's action,
  with `sudo`, file by file.
- **No `systemctl`.** `services-*.txt` *declares* units; the installer prints
  them and never enables, starts or checks one. A clean `--check` is not
  evidence the session is complete.
- **No install of phiOS's own packages.** `phi`, `phi-shell` and the rest
  arrive through the `[phi]` pacman repo, listed in a profile's
  `packages.txt`.
- **No secrets, no addresses.** The `[phi]` mirror file ships a placeholder
  `Server =` line that nothing fills in.

## Comments

Document the system, not the history. Say what a thing does and why a
non-obvious choice was made; do not record when it changed or what it used to
be. Use `TODO:` for unfinished work and `FIXME:` for a known bug.

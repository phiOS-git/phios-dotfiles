# PROGRESS

Durable memory of the phiOS step loop. One row per step from `phios-agent-brief.md` §6
(the main-line backlog). This file is updated in the same commit as the step that
changes a row's status — never in a separate commit.

## Status legend

- `todo` — not started.
- `awaiting-verification` — the agent has written, committed, and pushed to `github`;
  waiting on the user to run the step's `VERIFY` block and confirm `DONE WHEN`.
- `verified` — the user has confirmed `DONE WHEN`. The next step's commit is what
  moves a row from `awaiting-verification` to `verified` and fills in the `Commit`
  column, because a commit cannot record its own hash in advance.
- `blocked` — cannot proceed; see `Note` for what is missing and who owns closing it.

## M0 — Dotfiles foundation

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-00 | Repository scaffolding and PROGRESS.md | verified | 1e35eb6 | 2026-09-07 | |
| S-01 | [BLOCKING] Dotfiles v2 structure and installer | verified | 6712fdb | 2026-09-07 | Machinery only; `profiles/` stays empty until S-03, so `--dry-run` reports no profiles declared |
| S-02 | [BLOCKING] Design token source, two variants | verified | ac8b04e | 2026-09-07 | `Q-N01` (`font-mono`) still open, provisional value written, closes at S-51. Light variant has never rendered on a machine |
| S-03 | [BLOCKING] Migrate existing targets, output-identical | verified | b97f3f4 | 2026-09-07 | `modules/`, `install.sh` and `theme.sh` removed. All six templates verified byte-identical against the pre-S-03 renderer, **dark variant only, off-machine** — light has no pre-S-03 output to be identical to, but both variants define the same token set and all 32 tokens the templates use resolve non-empty in light. Two rendered files still carry the stale Italian header `Generato da theme.sh` — kept byte-for-byte on purpose, so the dry-run shows the renders as `ok` and only the symlinks move; retranslating them is a one-line change for whichever step next touches them. Profile order is preserved in `hosts/*.txt`, but `phios-install` batches every missing package into one `pacman` transaction instead of one call per profile, so that order no longer drives behaviour the way `install.sh` did — the `vulkan-driver` regression is avoided by the single transaction, not by the ordering, and neither is verified on a fresh machine. `profiles/workstation`, `study` and `server` are declared and empty |
| S-04 | Capability detection | verified | abdfa82 | 2026-09-07 | `bin/phios-capabilities` probes `/sys` and `/proc` only (coreutils budget, R9): no `lspci`, `libinput` or `udevadm`. GPU vendor reads the PCI vendor id from `/sys/class/drm/card*/device/vendor`. Touchscreen/touchpad have no dedicated sysfs class, so they match the device's own reported name in `/proc/bus/input/devices` — a heuristic, unverified against real hardware. ALS matches an iio device name containing "light" or "als", since S-06 (which fixes the real driver name) is still open. Chroma detection matches any USB device carrying Razer's vendor ID (1532), not the keyboard specifically, since no per-model check was available to write against. None of this ran on `zotac` or `razer`; only exercised off-machine, where every capability correctly reports false/none |
| S-05 | /etc boundary | awaiting-verification | | 2026-09-07 | `--system-diff` needed no code change — generic since S-01/S-03 (`phios_system_collect`/`phios_system_diff`, `bin/lib/system.sh`), so this step is entirely content: `profiles/*/system/` populated per host. `nvidia` (zotac): `modprobe.d/nvidia.conf`. `workstation` (zotac, was declared-empty since S-03 — README rewritten): `zram-generator.conf`, `sysctl.d/99-zram.conf`, and the two-disk `crypttab` shape (root via `crypttab.initramfs`, `bulk` cascading in `crypttab`) — UUIDs are machine data, left as `<system-partition-uuid>`/`<bulk-partition-uuid>` placeholders, a permanent expected `--system-diff` difference. `server` (mini, was declared-empty since S-03 — README rewritten): `zram-generator.conf` (mini's own `min(ram / 2, 4096)` sizing, distinct from zotac's fixed `8192`), `sysctl.d/99-zram.conf`, `smartd.conf` (missing `/dev/sdb1` on purpose — deferred on `mini` itself per `mini-procedura-base.md` note 9), and the two-unit `OnFailure=` notify-on-failure drop-in — `Description=`/`ExecStart=` written in English per this repo's language rule, so the first diff against the live Italian strings is expected and reconciled by editing the machine (the inverse of S-03's call to leave `Generato da theme.sh` alone: that file had no repo-side canonical text to reconcile against, this one does). `laptop` (razer): the suspend/hibernate drop-ins (`sleep.conf.d/10-hibernate-delay.conf`, `logind.conf.d/10-lid.conf`) from `razer-procedura-completata.md` §13 — not on the card's explicit list, added because the goal sentence ("what is currently applied by hand and known") is the requirement and these are exactly that; flagged here for cheap veto. `multilib` is a **note**, not a mirrored file: pacman.conf has no drop-in/include mechanism for repository sections, so there is no real absolute path to diff a fragment against; it now lives in `profiles/gaming/manual.txt` (covers exactly `{zotac, razer}`, the hosts that need it) instead. That file's sed script needed `$'\x23'` ANSI-C quoting in place of a literal `#`, because `phios_read_list` truncates every line at its first `#` with no notion of quoting — a latent gap in the shared list parser, worked around locally rather than fixed, since fixing it touches every profile's `manual.txt`/`services-*.txt` and no other entry has ever needed a `#`. Deliberately NOT captured, because each is a partial edit to a package-owned file rather than a self-contained fragment at its own path — no mechanism here fits them, and they stay recorded only in `docs/*procedura*.md`: `mkinitcpio.conf` (`MODULES=`, `HOOKS=`), `/boot/loader/entries/*.conf`, `/etc/fstab`. Also not written: `/usr/local/bin/notify.sh` (outside the `/etc` boundary, and the live copy on `mini` has the `ntfy.sh` topic baked in at generation time — a notification topic, which no repository may hold; noted instead in `profiles/server/README.md`). `smartd.conf`'s `-m <nomailer>` token is copied byte-for-byte from `mini-procedura-base.md`; unverified against `smartd.conf(5)` whether that is the documented literal syntax for "no mail, `-M exec` only" or a placeholder the original doc left unfilled — man page not reachable from here. Self-check performed off-machine only: `bin/phios-install --host {zotac,razer,mini} --system-diff` for all three — every declared file appears exactly once, 0 unreadable, all report as new-file diffs against `/dev/null` (expected, since this machine has none of these `/etc` paths); `phios_manual_report` exercised directly to confirm the multilib line prints whole. `--dry-run`/`--check` could not be smoke-tested here at all — pre-existing, unrelated to this step: they fail on macOS's BSD `realpath` (`illegal option -- m`) before reaching any code this step touches; confirmed by reproducing the identical failure on the pre-S-05 commit. Also fixed in this commit: a comment in `bin/lib/system.sh` and a bullet in `README.md` both claimed "`--check`'s service-drift gap closes at S-05" — false, and disproven by this step: the installer never queries systemd, by design, so that gap cannot close at any step. Nothing here ran on `zotac`, `razer` or `mini` |
| S-06 | razer input diagnostics | todo | | | |

## M1 — phi and own-package distribution

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-10 | [BLOCKING] phi repository skeleton and --version | todo | | | |
| S-11 | [BLOCKING] phi-packages and the [phi] pacman repository | todo | | | |
| S-12 | phi theme | todo | | | |
| S-13 | phi state | todo | | | |
| S-14 | phi doctor | todo | | | |
| S-15 | phi completions and packaging polish | todo | | | |

## M2 — Shell skeleton and status bar

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-20 | [BLOCKING] phi-shell repository and configuration singletons | todo | | | |
| S-21 | Styled widget library | todo | | | |
| S-22 | [BLOCKING] Status bar with declarative module registry | todo | | | |
| S-23 | Bar modules | todo | | | |
| S-24 | Session integration | todo | | | |
| S-25 | Compatibility check against Hyprland | todo | | | |

## M3 — Session surfaces

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-30 | Notification daemon and toasts | todo | | | |
| S-31 | [BLOCKING] Sidebar with declarative tab registry | todo | | | |
| S-32 | Clipboard history | todo | | | |
| S-33 | [BLOCKING] Launcher | todo | | | |
| S-34 | Lock screen | todo | | | |
| S-35 | Window overview | todo | | | |
| S-36 | Screenshot, OCR, QR, recording | todo | | | |
| S-37 | Alt+Tab overlay, tooltips, context menu, cheat sheet | todo | | | |
| S-38 | Keybinding scheme | todo | | | |
| S-39 | Daily-use consolidation | todo | | | |

## M4 — Settings panel and system features

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-40 | [BLOCKING] Settings panel, nine sections | todo | | | |
| S-41 | Live light/dark theme, GTK/Qt, CSD decision | todo | | | |
| S-42 | Night shift and True Tone | todo | | | |
| S-43 | Cursor spotlight, idle inhibit, OSD, timer, colour picker, fullscreen auto-hide bar | todo | | | |
| S-44 | Wallpaper | todo | | | |
| S-45 | Package management surface and theme regeneration hook | todo | | | |
| S-46 | razer hardware: hwdb fix and Chroma | todo | | | |

## M5 — Identity and advanced styling

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-50 | Final palette, derived in OKLCH | todo | | | |
| S-51 | Typography and the patched-font correction | todo | | | |
| S-52 | Motion implementation | todo | | | |
| S-53 | Plymouth boot theme and Φ identity assets | todo | | | |
| S-54 | Cursor theme, magnifier, remaining chrome | todo | | | |

## M6 — Services and tools

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-60 | Synchronised cloud | todo | | | |
| S-61 | Photo library | todo | | | |
| S-62 | Jellyfin and the video libraries | todo | | | |
| S-63 | Indexers and download client | todo | | | |
| S-64 | Media and music pipelines | todo | | | |
| S-65 | ClamAV | todo | | | |
| S-66 | LanguageTool | todo | | | |
| S-67 | Office, study tools, secrets | todo | | | |
| S-68 | Clipboard continuity between zotac and razer | todo | | | |

## M7 — AI agent

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-70 | [BLOCKING] Containment and its proof | todo | | | |
| S-71 | Credential brokering | todo | | | |
| S-72 | A2 network whitelist | todo | | | |
| S-73 | Agent data model and phi MCP server | todo | | | |
| S-74 | Inline command line and remote surface | todo | | | |
| S-75 | Shell panel: connect the placeholder | todo | | | |
| S-76 | Transition from the current uncontained usage | todo | | | |

## M8 — Custom applications

| Step | Title | Status | Commit | Date | Note |
|---|---|---|---|---|---|
| S-80 | phi-notes | todo | | | |
| S-81 | Language decision checkpoint | todo | | | |
| S-82 | phi-music | todo | | | |
| S-83 | phi-media | todo | | | |

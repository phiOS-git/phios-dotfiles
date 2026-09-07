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
| S-03 | [BLOCKING] Migrate existing targets, output-identical | awaiting-verification | | 2026-09-07 | `modules/`, `install.sh` and `theme.sh` removed. All six templates verified byte-identical against the pre-S-03 renderer, **dark variant only, off-machine** — light has no pre-S-03 output to be identical to, but both variants define the same token set and all 32 tokens the templates use resolve non-empty in light. Two rendered files still carry the stale Italian header `Generato da theme.sh` — kept byte-for-byte on purpose, so the dry-run shows the renders as `ok` and only the symlinks move; retranslating them is a one-line change for whichever step next touches them. Profile order is preserved in `hosts/*.txt`, but `phios-install` batches every missing package into one `pacman` transaction instead of one call per profile, so that order no longer drives behaviour the way `install.sh` did — the `vulkan-driver` regression is avoided by the single transaction, not by the ordering, and neither is verified on a fresh machine. `profiles/workstation`, `study` and `server` are declared and empty |
| S-04 | Capability detection | todo | | | |
| S-05 | /etc boundary | todo | | | |
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

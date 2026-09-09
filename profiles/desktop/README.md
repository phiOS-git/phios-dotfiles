# desktop

`zotac` and `razer`. The two machines with a graphical session: `phi-shell`
plus the Hyprland Lua configuration that starts it (S-20–S-24).

`templates/.config/hypr/hyprland.lua.tmpl` became a template at S-54, for
one substitution (`XCURSOR_THEME`/`XCURSOR_SIZE`, master plan §6.7 class A —
"Hyprland" is one of that class's own named targets, `hyprctl reload` is
its real reload command). It was a plain `home/` file through S-53:
Hyprland's Lua config had no design-token substitution point in use before
then, so nothing in it was generated. Everything else in the file is still
ordinary Lua, unrelated to this change. `home/.config/kitty/` and
`templates/` carry the themed terminal/file-manager/media-player configs
(design tokens flow through `templates/`, S-01–S-02).

## Hyprland Lua API compatibility (S-25, risk C-06)

Master plan §18 flags the Lua configuration API as "in movimento": Hyprland
was on 0.55 when `zotac`/`razer`'s procedures were written and `extra`
already carries 0.56.x. This section is the record risk C-06 asks for —
which API surfaces `hyprland.lua` depends on, and confirmation that none of
them is deprecated — kept here so it is updated in place the next time this
file changes, rather than re-derived from scratch.

**Reviewed against** (2026-09-08, off-machine — see the open item below):
`hyprwm/Hyprland`'s own `example/hyprland.lua` and the rendered
`hyprwm/hyprland-wiki` pages for binds, dispatchers, window rules,
workspace rules, autostart, and events, fetched directly rather than
summarized (the wiki's own pages sit behind a JS proof-of-work checkpoint
this agent cannot solve). Cross-checked at two points: the `v0.56.2` tag
(the version `extra` carries per master plan §18) and the `main` branch
tip. The two differ, for `example/hyprland.lua`, by exactly one unrelated
line (a `dampening` → `damping` typo fix in a spring curve this config
never uses) — everything this file calls is unchanged between them.

| Symbol | Used at | Confirmed against |
|---|---|---|
| `hl.monitor({...})` | monitors block | `example/hyprland.lua`, byte-identical shape |
| `hl.on("hyprland.start", fn)` | autostart block | `configuring/core/autostart.md`; event confirmed real in `advanced-configuration/events.md` |
| `hl.exec_cmd(cmd)` | inside the `hyprland.start` handler | `advanced-configuration/lua-utilities.md` — real top-level convenience function, distinct from the `hl.dsp.exec_cmd` dispatcher-builder used in binds |
| `hl.bind(keys, hl.dsp.exec_cmd(...))` | app/window keybindings | `example/hyprland.lua`, byte-identical for the terminal/browser/file-manager and the `hyprshutdown`-or-`hl.dsp.exit()` shutdown bind — that exact fallback line is copied verbatim in upstream's own example, not invented here |
| `hl.dsp.window.close()` | `SUPER+Q` | `configuring/core/dispatchers.md` §Window: `close({ window? })`, `window` optional |
| `hl.dsp.focus({ direction = ... })` | arrow-key focus binds | `configuring/core/dispatchers.md` §General: `focus({ direction })` |
| `hl.workspace_rule({ workspace, persistent })` | btop's special workspace | `configuring/core/rules/workspace-rules.md` — `persistent` is a real, current field; `special:<name>` matches the doc's own `special:scratchpad` example |
| `hl.window_rule({ name, match = { class }, workspace })` | btop and Steam rules | `configuring/core/rules/window-rules.md` — `class` is a real `match` prop; `workspace` effect confirmed to accept the `" silent"` suffix used on the btop rule, exactly as documented |

**Result: no deprecation found.** Every symbol this file calls is present,
unchanged in shape, and not flagged deprecated anywhere in the Hyprland
`v0.55.0`→`v0.56.2` release notes (scanned for every entry mentioning
`lua`) or in the current wiki. The one open question S-24 left for this
step — whether `hyprland.start` can refire on a plain `hyprctl reload` — is
resolved: the events reference documents it as "Emitted once on start", so
it cannot; see the comment above `hl.on("hyprland.start", ...)` in
`hyprland.lua` for the fix this unblocked.

**Not in scope here:** `phi-shell`'s own `Quickshell.Hyprland` usage
(`Services/HyprlandBridge.qml` — workspace list, active window, read over
Hyprland's IPC socket rather than the Lua config) is a different
dependency, already tracked under master plan §18's separate "API di
quickshell non stabile" risk row — a Quickshell-side instability, not a
Hyprland Lua one, so re-auditing it here would blur two distinct risks
together.

**Still open, genuinely unverifiable from here:** this review is against
upstream's own reference sources, not the version actually running on
`zotac`/`razer` — this agent has no path to either machine (`CLAUDE.md`
rule 4). `DONE WHEN` needs `hyprctl version` and `pacman -Qi hyprland` from
both, plus a check of the real session log for any `deprecat*` string
Hyprland itself printed at load — the real log path, confirmed from
`hyprwm/hyprland-wiki`'s crashes-and-bugs page rather than guessed, is
`$XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log` (most recent instance:
`` $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log ``).

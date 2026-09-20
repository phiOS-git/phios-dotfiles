# desktop

`zotac` and `razer`. The two machines with a graphical session: `phi-shell`
plus the Hyprland Lua configuration that starts it.

`templates/.config/hypr/hyprland.lua.tmpl` is a template with one substitution
(`XCURSOR_THEME`/`XCURSOR_SIZE` — "Hyprland" is a target that uses `hyprctl
reload` to pick up changes). It was originally a plain `home/` file; Hyprland's
Lua config had no design-token substitution point in use, so nothing in it was
generated. Everything else in the file is still ordinary Lua, unrelated to this
change. `home/.config/kitty/` and `templates/` carry the themed terminal/
file-manager/media-player configs (design tokens flow through `templates/`).

## Hyprland Lua API compatibility

The Lua configuration API can change between versions. Hyprland was on 0.55
when the procedures were written and `extra` now carries 0.56.x. This section
documents which API surfaces `hyprland.lua` depends on and confirms that none
of them are deprecated — kept here so it is updated in place the next time this
file changes, rather than re-derived from scratch.

**Reviewed against** (2026-09-08, off-machine — see the open item below):
`hyprwm/Hyprland`'s own `example/hyprland.lua` and the rendered
`hyprwm/hyprland-wiki` pages for binds, dispatchers, window rules,
workspace rules, autostart, and events, fetched directly rather than
summarized (the wiki's own pages sit behind a JS proof-of-work checkpoint
this agent cannot solve). Cross-checked at two points: the `v0.56.2` tag
(the version `extra` carries) and the `main` branch tip. The two differ, for
`example/hyprland.lua`, by exactly one unrelated line (a `dampening` →
`damping` typo fix in a spring curve this config never uses) — everything
this file calls is unchanged between them.

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
Hyprland's IPC socket rather than the Lua config) is a different dependency
and a Quickshell-side concern — a Quickshell instability, not a Hyprland Lua
one, so auditing it here would blur two distinct concerns together.

**Still open, genuinely unverifiable from here:** this review is against
upstream's own reference sources, not the version actually running on
`zotac`/`razer` — this agent has no path to either machine (`CLAUDE.md`
rule 4). `DONE WHEN` needs `hyprctl version` and `pacman -Qi hyprland` from
both, plus a check of the real session log for any `deprecat*` string
Hyprland itself printed at load — the real log path, confirmed from
`hyprwm/hyprland-wiki`'s crashes-and-bugs page rather than guessed, is
`$XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log` (most recent instance:
`` $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log ``).

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local browser      = "librewolf"
local fileManager  = "kitty -e yazi"

-------------------
---- AUTOSTART ----
-------------------

-- Quickshell must stay checked out at exactly this path (phi-shell/README.md).
-- Named once here and reused by every `qs ipc call` below (PHI-SHELL
-- KEYBINDINGS section) via qsIpc(), rather than repeating the literal:
-- `qs ipc call` with no `-p`/`-c` targets Quickshell's "default" config
-- (`<xdg dir>/quickshell/shell.qml`, confirmed by reading Quickshell's own
-- src/launch/parsecommand.cpp), and phi-shell is launched below as a named
-- path, not that default, so every call must repeat this same `-p`.
local qsConfigPath = "~/.config/quickshell/phi"

-- phi-shell starts with the session (S-24, ADR 072: one shell, not
-- independent components). Confirmed at S-25 against the real upstream
-- event reference (hyprwm/hyprland-wiki, advanced-configuration/events):
-- `hyprland.start` is documented as "Emitted once on start", i.e. it does
-- not refire on a plain `hyprctl reload` — a reload tears down and
-- reconstructs the Lua state (`config.unload`, then the script runs again
-- top to bottom), but that is a different thing from `hyprland.start`
-- itself firing twice. The `pgrep` guard was never actually defending
-- against a refire that could happen; it stays anyway as free, harmless
-- insurance against any other path that might run this same script twice.
-- Editing QML afterward never needs this to run again: Quickshell
-- hot-reloads its own files on save (master plan §8.1). See
-- phi-shell/README.md for restarting `qs` itself without a session reload.
hl.on("hyprland.start", function ()
    hl.exec_cmd("pgrep -x qs >/dev/null || qs -p " .. qsConfigPath)
end)

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- apps
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

-- windows managing
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

--------------------------------
---- PHI-SHELL KEYBINDINGS  ----
--------------------------------

-- S-38: "propose a complete scheme... Super for the window manager, Alt
-- for applications, modes for rare actions" (master plan). Every M2/M3
-- shell surface reaches this way, all through the same `qs ipc call
-- <target> <fn>` mechanism S-31 established and every surface since has
-- followed — via qsIpc() below, which prepends the `-p` targeting
-- phi-shell's own instance (see qsConfigPath's own note under AUTOSTART
-- above for why that flag is required, not optional).
--
-- The pre-existing Super+Return/B/E/Q/arrows/M binds above (S-24) are
-- deliberately left untouched, even though app-launching sits oddly
-- against "Alt for applications" read strictly: no real keybinding has
-- ever been used on real hardware yet (every M2/M3 step's own note, most
-- recently S-37's), so there is no muscle memory here to protect, but
-- treating "open a terminal" as basic window-manager-level functionality
-- (as most tiling WM configs do) rather than an "application" in the
-- Alt-Tab sense is this agent's own reading, not a document's — flagged
-- for the user's own amend, exactly as this step's DONE WHEN asks for
-- ("the user confirms the scheme is the one they want to learn").
local function qsIpc(target, fn)
    return "qs -p " .. qsConfigPath .. " ipc call " .. target .. " " .. fn
end

hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(qsIpc("launcher", "toggle")))    -- architettura §8.2.2 S1: "Runner con Super+Spazio", verbatim
hl.bind(mainMod .. " + N",     hl.dsp.exec_cmd(qsIpc("sidebar", "toggle")))     -- N for the sidebar's own default tab, Notifications
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd(qsIpc("lock", "lock")))          -- universal desktop-environment convention
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(qsIpc("overview", "toggle")))    -- window-manager-level "show every window", distinct from Alt+Tab's per-application cycling below
-- "slash" (lowercase), not "Slash": X11/XKB keysym names for punctuation
-- are lowercase words (matching "left"/"right"/"up"/"down" above), unlike
-- named keys like "Return"/"Tab"/"Escape", which are capitalized.
hl.bind(mainMod .. " + SHIFT + slash", hl.dsp.exec_cmd(qsIpc("cheatsheet", "toggle"))) -- Super+? — common "show shortcuts" convention

-- Alt+Tab (S-37, architettura §8.2.2 S10): the one binding that genuinely
-- fits "Alt for applications" — cycling BETWEEN running applications is
-- exactly that, and matches the universal Alt+Tab convention besides.
-- Three ways out of the submap (Alt release, Escape, catchall) so a
-- stray keypress can never leave the session stuck inside it (the real
-- documentation's own explicit warning: "Do not forget a keybind to
-- reset the keymap while inside it!").
hl.bind("ALT + Tab", hl.dsp.submap("alttab"))

hl.define_submap("alttab", function()
    -- Binding "ALT + Tab" again inside the submap, not a bare "Tab": Alt
    -- is still physically held from entering the submap, and this
    -- project has no confirmed source for whether Hyprland's submap key
    -- matching requires an exact modifier-state match the way a normal
    -- global bind does — repeating the held modifier is the safer
    -- reading, not a confirmed one; flagged for cheap veto if cycling
    -- does not respond to a second Tab press on real hardware.
    hl.bind("ALT + Tab", hl.dsp.exec_cmd(qsIpc("alttab", "next")))
    hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(qsIpc("alttab", "prev")))

    -- Releasing Alt confirms and exits — the actual mechanism S-37's own
    -- card names ("release Alt exits the mode and confirms").
    hl.bind("ALT_L", function()
        hl.dispatch(hl.dsp.exec_cmd(qsIpc("alttab", "confirm")))
        hl.dispatch(hl.dsp.submap("reset"))
    end, { release = true })

    hl.bind("Escape", function()
        hl.dispatch(hl.dsp.exec_cmd(qsIpc("alttab", "cancel")))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
    hl.bind("catchall", function()
        hl.dispatch(hl.dsp.exec_cmd(qsIpc("alttab", "cancel")))
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end)

-- Screenshot/OCR/QR/recording (S-36): a "mode for a rare action" (master
-- plan's own third category), not five-plus separate modifier chords —
-- Print enters the mode, one mnemonic letter picks the action, every
-- action exits back to the global keymap on its own (the documented
-- "same keybind performs multiple actions" pattern, factored through one
-- local helper rather than repeated seven times).
hl.bind("Print", hl.dsp.submap("screenshot"))

hl.define_submap("screenshot", function()
    local function fireAndReset(cmd)
        return function()
            hl.dispatch(hl.dsp.exec_cmd(cmd))
            hl.dispatch(hl.dsp.submap("reset"))
        end
    end

    hl.bind("a", fireAndReset(qsIpc("screenshot", "area")))
    hl.bind("w", fireAndReset(qsIpc("screenshot", "window")))
    hl.bind("f", fireAndReset(qsIpc("screenshot", "fullscreen")))
    hl.bind("o", fireAndReset(qsIpc("screenshot", "ocr")))
    hl.bind("q", fireAndReset(qsIpc("screenshot", "qr")))
    hl.bind("r", fireAndReset(qsIpc("record", "start")))
    hl.bind("SHIFT + r", fireAndReset(qsIpc("record", "stop")))
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- Deliberately NOT bound to anything: Widgets/ContextMenu.qml (mouse-
-- driven, and unwired to any surface by the user's own S-37 decision) and
-- Tooltip/Tooltip.qml (hover-driven, no keyboard trigger makes sense for
-- either).

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Dynamic workspaces (master plan §2.3, a closed decision) need no rule at
-- all: Hyprland creates a workspace on first use and destroys it once empty
-- by default, which already is "dynamic". What would violate the decision
-- is a static monitor-pinned or `default = true` workspace assignment —
-- deliberately not added here. `btop`'s special workspace below is the one
-- intentional exception, kept alive on purpose rather than reclaimed the
-- moment it is hidden.

-- btop workspace (ADR 122 / Q-N03, closed at S-22): a dedicated special
-- workspace, not a normal high-numbered one. `Bar/modules/Gpu.qml`
-- (phi-shell, S-23/S-24) launches btop as `kitty --class phios-btop -e
-- btop` specifically so this rule can match the terminal's own Wayland app
-- id — set once at launch and never touched again — rather than its
-- window title, which btop's own TUI can rewrite at runtime.
--
-- REAL-HARDWARE FIX (razer, first verification round): the first version
-- of this rule assigned the window with a bare `workspace = "special:btop"`
-- — no `silent` suffix — which switches the monitor's active workspace to
-- it the moment the window opens, exactly like a normal (non-special)
-- workspace assignment does. Evidence: a `hyprctl clients` capture taken
-- right after testing this showed the user's own terminal AND Steam itself
-- both sitting on `special:btop`, because nothing (no keybinding exists
-- yet, S-38) could switch back out of it once btop's launch silently
-- dragged the whole session in. `silent` is exactly what suppresses that
-- forced switch (confirmed against real Hyprland source: the window-rule
-- `workspace` field "can be `unset` or suffixed with ` silent`") — the
-- window still lands on the special workspace, nothing else moves there
-- with it, and it is only actually seen once something calls
-- `togglespecialworkspace btop` (still no bar toggle wired for that,
-- flagged in S-22's own PROGRESS row and left alone here per the user's
-- own instruction not to build it as a side effect of this fix).
hl.workspace_rule({
    workspace  = "special:btop",
    persistent = true,
})

hl.window_rule({
    name  = "btop-workspace",
    match = { class = "^phios-btop$" },

    workspace = "special:btop silent",
})

-- Steam (master plan §2.3: dedicated workspace, secondary windows
-- floating). The main-window rule below is real, not guessed: `hyprctl
-- clients` on razer (this step's VERIFY round-trip) showed Steam's actual
-- window as `class: steam, title: Steam, initialClass: steam` — used
-- directly, no placeholder. Given its own dedicated, always-visible
-- workspace (unlike btop's hidden special one) makes sense for something
-- you deliberately switch to, this is a plain named workspace, not special,
-- and not `silent` — opening Steam is meant to take you there.
hl.window_rule({
    name  = "steam-workspace",
    match = { class = "^steam$" },

    workspace = "name:steam",
})

-- "Secondary windows floating" is still NOT written: the one real Steam
-- window captured so far is the main library window itself (title
-- "Steam"). Distinguishing a secondary window (Friends List, a chat, a
-- game's own popup) needs either that window's own title from a real
-- `hyprctl clients` capture, or confirmation of how to negate a match in
-- this Hyprland version — real sources disagree on whether its regex
-- engine even supports a negative-lookahead title match at all (some
-- describe ECMA-262 semantics, others RE2 with a separate `negative:`
-- prefix instead), so guessing the mechanism is exactly the same mistake
-- as guessing a class name. Add once a secondary window's real title is
-- captured:
--
-- hl.window_rule({
--     name  = "steam-secondary-float",
--     match = { class = "^steam$", title = "<secondary-title-regex>" },
--     float = true,
-- })

-----------------
---- GESTURES ----
-----------------

-- Window overview recall gesture (S-35, master plan shell doc §13): three-
-- finger swipe on razer's touchpad, mirroring the "opposite axis to the
-- L/R workspace switch, so no conflict" requirement — Hyprland's own
-- built-in workspace-swipe gesture already owns left/right, so up opens
-- and down closes, matching a common show/dismiss convention rather than
-- both directions doing the same toggle. Syntax confirmed against the
-- real Hyprland wiki source (hyprwm/hyprland-wiki, configuring/core/
-- binds/gestures.md) rather than assumed — this project's own risk C-06
-- flag on a fast-moving Lua config API applies here as much as anywhere
-- else in this file. Inert on zotac: gestures need touchpad hardware
-- that machine does not have, so no host-specific guard is needed, the
-- same capability-driven default this project already uses everywhere
-- else (ADR 074).
hl.gesture({
    fingers = 3,
    direction = "up",
    action = function() hl.exec_cmd(qsIpc("overview", "open")) end,
})
hl.gesture({
    fingers = 3,
    direction = "down",
    action = function() hl.exec_cmd(qsIpc("overview", "close")) end,
})

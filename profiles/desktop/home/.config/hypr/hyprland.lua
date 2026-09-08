---------------------
---- ENVIRONMENT ----
---------------------

-- S-41 (theme, Q-N05 "suppress CSD" decision this session) and the GTK/Qt
-- native-app theming target group (master plan §6.7). `hl.env()` sets a
-- variable before the display server initializes — confirmed against the
-- real Hyprland wiki source (hyprwm/hyprland-wiki, configuring/core/
-- environment-variables.md), which documents QT_QPA_PLATFORMTHEME=qt6ct as
-- its own worked example for exactly this purpose, not guessed.
--
-- QT_WAYLAND_DISABLE_WINDOWDECORATION disables Qt's OWN window chrome under
-- Wayland outright — the same wiki page's own documented variable, and a
-- more direct CSD fix for Qt than GTK_CSD is for GTK (Qt does not have
-- libadwaita's "hardcodes its own HeaderBar" problem: this one variable is
-- unconditional, not "wherever the toolkit exposes a setting").
--
-- GTK_CSD=0 is real and documented (GNOME/gtk#760, PCMan/gtk3-nocsd) but
-- KNOWN INCOMPLETE for GTK4/libadwaita apps, which need either GTK_THEME
-- forced or an LD_PRELOAD shim (GTK-NoCSD) neither of which phiOS can add
-- under Q-01 (AUR/manual-build excluded) — accepted and documented, not
-- silently narrowed: GTK3 apps and non-libadwaita GTK4 apps suppress
-- cleanly, libadwaita apps (most modern GNOME apps) keep their header bar.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GTK_CSD", "0")

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

-- S-42: hyprsunset with NO config file and NO CLI profile args — started
-- bare, at a neutral default (identity, no colour shift) and left entirely
-- to `hyprctl hyprsunset` IPC calls from Services/NightShift.qml (phi-shell)
-- from then on. A ~/.config/hypr/hyprsunset.conf profile schedule would
-- fight with that: the wiki's own doc says a new profile activation "resets
-- all options set by other profiles", so a clock-based profile would
-- silently overwrite whatever NightShift.qml's own toggle/temperature state
-- had just set. No profile file is written on purpose.
hl.on("hyprland.start", function ()
    hl.exec_cmd("pgrep -x hyprsunset >/dev/null || hyprsunset")
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

-- `{ description = ... }` on every phi-shell bind below is a real,
-- documented `hl.bind()` flag (hyprwm/hyprland-wiki,
-- configuring/core/binds/flags.md: "You can describe your keybind with
-- the description flag... use hyprctl binds" to read it back) — found
-- needed on real hardware: without it, every Lua-callback bind shows up
-- in `hyprctl binds -j` as an opaque internal dispatcher/arg pair (seen
-- literally as "_lua 16"), which is what Cheatsheet.qml was rendering
-- verbatim for lack of anything better to show.
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(qsIpc("launcher", "toggle")), { description = "Toggle the launcher" })    -- architettura §8.2.2 S1: "Runner con Super+Spazio", verbatim
hl.bind(mainMod .. " + N",     hl.dsp.exec_cmd(qsIpc("sidebar", "toggle")), { description = "Toggle the sidebar" })     -- N for the sidebar's own default tab, Notifications
hl.bind(mainMod .. " + S",     hl.dsp.exec_cmd(qsIpc("settings", "toggle")), { description = "Toggle settings" })      -- S-40: no prior bind claimed S, obvious mnemonic
hl.bind(mainMod .. " + G",     hl.dsp.exec_cmd(qsIpc("spotlight", "toggle")), { description = "Toggle the cursor spotlight" }) -- S-43: "G" for "glow" -- no closer mnemonic was free ("F"/"L" already used)
hl.bind(mainMod .. " + L",     hl.dsp.exec_cmd(qsIpc("lock", "lock")), { description = "Lock the screen" })          -- universal desktop-environment convention
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(qsIpc("overview", "toggle")), { description = "Toggle the window overview" })    -- window-manager-level "show every window", distinct from Alt+Tab's per-application cycling below
-- "slash" (lowercase), not "Slash": X11/XKB keysym names for punctuation
-- are lowercase words (matching "left"/"right"/"up"/"down" above), unlike
-- named keys like "Return"/"Tab"/"Escape", which are capitalized.
hl.bind(mainMod .. " + SHIFT + slash", hl.dsp.exec_cmd(qsIpc("cheatsheet", "toggle")), { description = "Toggle the cheat sheet" }) -- Super+? — common "show shortcuts" convention

-- S-46: fixed volume/brightness keys (funzionalita §2.15, C-09). S-06's
-- own diagnosis already found the kernel reports STANDARD, correctly-named
-- codes for every one of these (KEY_MUTE, KEY_VOLUMEUP/DOWN,
-- KEY_BRIGHTNESSUP/DOWN, i.e. Hyprland's XF86Audio*/XF86MonBrightness*
-- keysyms) — no hwdb rule was ever needed, the actual gap this whole time
-- was simply that no bind existed yet (S-06's own words: "almost
-- certainly the absence of any compositor keybinding"). `repeating = true,
-- locked = true` on the brightness binds matches the real Hyprland wiki's
-- own worked example for this exact keysym pair (configuring/core/
-- environment-variables.md's hyprsunset-gamma example) — `locked` so they
-- still work from the lock screen, which volume/brightness genuinely
-- should.
--
-- Volume goes straight to wpctl (WirePlumber's own CLI, real/standard),
-- not through phi-shell: Services/AudioBridge.qml already reflects live
-- PipeWire state reactively, regardless of which process changed it, so
-- there is nothing phi-shell needs to be told. Brightness is NOT like
-- that — Services/Brightness.qml caches `percent` from its own
-- brightnessctl reads, so it goes through `qs ipc call brightness up/down`
-- (that file's own S-46 IpcHandler) instead of a bare brightnessctl call,
-- so the OSD (S-43) updates atomically rather than going stale.
-- Bare key name, ONE string argument, no modifier prefix — matches the
-- real wiki's own worked example exactly (hl.bind("XF86MonBrightnessUp",
-- ...)), not a two-argument hl.bind("", "Key", ...) form, which an
-- earlier draft of this file used and which no source here confirms.
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(qsIpc("brightness", "down")), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(qsIpc("brightness", "up")), { repeating = true, locked = true })

-- Alt+Tab (S-37, architettura §8.2.2 S10): the one binding that genuinely
-- fits "Alt for applications" — cycling BETWEEN running applications is
-- exactly that, and matches the universal Alt+Tab convention besides.
-- Three ways out of the submap (Alt release, Escape, catchall) so a
-- stray keypress can never leave the session stuck inside it (the real
-- documentation's own explicit warning: "Do not forget a keybind to
-- reset the keymap while inside it!").
--
-- Found on real hardware: the FIRST Alt+Tab press only entered the
-- submap — it did not also show the overlay or select a window, which
-- needed a second, separate Tab press to reach the submap's own "ALT +
-- Tab" bind below. Fixed the same documented way the release/confirm
-- binds already use ("You can also set the same keybind to perform
-- multiple actions... the binds are executed in the order they appear",
-- submaps.md): entering the submap and calling next()/prev() now happen
-- together on the very first press. A new Alt+Shift+Tab entry point is
-- added for the same reason — found on real hardware to only work once
-- the submap was already open, since only the submap-local "ALT + SHIFT
-- + Tab" bind existed before.
local function enterAltTab(step)
    return function()
        hl.dispatch(hl.dsp.submap("alttab"))
        hl.dispatch(hl.dsp.exec_cmd(qsIpc("alttab", step)))
    end
end
hl.bind("ALT + Tab", enterAltTab("next"), { description = "Cycle to the next window" })
hl.bind("ALT + SHIFT + Tab", enterAltTab("prev"), { description = "Cycle to the previous window" })

-- Releasing Alt confirms and exits — the actual mechanism S-37's own card
-- names ("release Alt exits the mode and confirms"). This used to be bound
-- INSIDE hl.define_submap("alttab", ...) on ALT_L/ALT_R with { release =
-- true } — confirmed on real hardware to never fire on the first release,
-- root-caused (not guessed) against Hyprland's own issue tracker
-- (hyprwm/Hyprland#15785, closed without a fix by policy, not because it
-- was resolved): a modifier held continuously from BEFORE a submap is
-- entered does not fire its own release bind on its first release inside
-- that submap, only on a subsequent full press-and-release cycle already
-- inside it. Alt+Tab enters "alttab" with Alt already held, which is
-- exactly that case.
--
-- Moved here instead, to the GLOBAL keymap, with `submap_universal = true`
-- (confirmed real flag, hyprwm/hyprland-wiki content/configuring/core/
-- binds/flags.md: "Will be active no matter the submap") — this is a
-- materially different case from the one #15785 describes: the bind is
-- registered once, before Alt+Tab is ever pressed, not declared inside the
-- submap's own scope, so there is no "held from before entering THIS
-- bind's scope" to trip over. Safe to leave active outside Alt+Tab too
-- (e.g. AltGr on some keyboard layouts is physically the right Alt key):
-- AltTab.qml's own confirm() ignores the IPC call unless the overlay is
-- actually shown, so an unrelated Alt release elsewhere is a harmless
-- no-op, not a stray confirm. Return (inside the submap, below) stays as
-- the always-reliable path regardless of whether this one turns out to
-- fire — it is a fresh key press while already inside the submap, not a
-- modifier held from before entering it, so it never hits #15785 either
-- way.
local function confirmAndReset()
    hl.dispatch(hl.dsp.exec_cmd(qsIpc("alttab", "confirm")))
    hl.dispatch(hl.dsp.submap("reset"))
end
hl.bind("ALT_L", confirmAndReset, { release = true, submap_universal = true })
hl.bind("ALT_R", confirmAndReset, { release = true, submap_universal = true })

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

    hl.bind("Return", confirmAndReset)

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
hl.bind("Print", hl.dsp.submap("screenshot"), { description = "Enter the screenshot/recording mode" })

hl.define_submap("screenshot", function()
    local function fireAndReset(cmd)
        return function()
            hl.dispatch(hl.dsp.exec_cmd(cmd))
            hl.dispatch(hl.dsp.submap("reset"))
        end
    end

    hl.bind("a", fireAndReset(qsIpc("screenshot", "area")), { description = "Screenshot: select an area" })
    hl.bind("w", fireAndReset(qsIpc("screenshot", "window")), { description = "Screenshot: active window" })
    hl.bind("f", fireAndReset(qsIpc("screenshot", "fullscreen")), { description = "Screenshot: full screen" })
    hl.bind("o", fireAndReset(qsIpc("screenshot", "ocr")), { description = "Screenshot: OCR a selected area" })
    hl.bind("q", fireAndReset(qsIpc("screenshot", "qr")), { description = "Screenshot: decode a QR code in a selected area" })
    hl.bind("c", fireAndReset(qsIpc("colorpicker", "pick")), { description = "Screenshot: pick a colour" }) -- S-43
    -- Found on real hardware: `r` used fireAndReset like every other
    -- action here, which exits this submap immediately after starting a
    -- recording -- but recording is the one action here that spans time
    -- rather than firing once, so that left `SHIFT + r` (stop) bound
    -- only inside a submap the user had already been kicked out of.
    -- Confirmed by the user's own test: `qs ipc call record stop`
    -- directly worked, Shift+R did not -- the handler was always fine,
    -- the submap just was not active when Shift+R was pressed. `r`
    -- fires without resetting, staying in this submap so Shift+R stays
    -- reachable; only the stop action resets back to the global keymap.
    hl.bind("r", hl.dsp.exec_cmd(qsIpc("record", "start")), { description = "Start screen recording" })
    hl.bind("SHIFT + r", fireAndReset(qsIpc("record", "stop")), { description = "Stop screen recording" })
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

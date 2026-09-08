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

-- phi-shell starts with the session (S-24, ADR 072: one shell, not
-- independent components). `hyprland.start` is understood to fire once per
-- session, not on every `hyprctl reload` — unconfirmed against the real
-- installed version (that check is S-25's job), so the `pgrep` guard stays
-- as cheap, idempotent insurance either way: at worst a no-op string
-- compare, never a second `qs` racing the first for the same bar surface.
-- Quickshell must stay checked out at exactly `~/.config/quickshell/phi`
-- (phi-shell/README.md). Editing QML afterward never needs this to run
-- again: Quickshell hot-reloads its own files on save (master plan §8.1).
-- See phi-shell/README.md for restarting `qs` itself without a session
-- reload.
hl.on("hyprland.start", function ()
    hl.exec_cmd("pgrep -x qs >/dev/null || qs -p ~/.config/quickshell/phi")
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

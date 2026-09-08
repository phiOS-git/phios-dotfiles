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
hl.workspace_rule({
    workspace  = "special:btop",
    persistent = true,
})

hl.window_rule({
    name  = "btop-workspace",
    match = { class = "^phios-btop$" },

    workspace = "special:btop",
})

-- Steam (master plan §2.3: dedicated workspace, secondary windows
-- floating) is deliberately NOT written here. The S-24 step card is
-- explicit: "Steam window rules need real class and title values. Ask the
-- user for hyprctl clients output rather than guessing" — and this agent
-- has no path to either machine to run that command (CLAUDE.md rule 4).
-- Add real rules once `hyprctl clients` output comes back from the
-- USER/VERIFY round-trip below (Steam's main window plus one secondary
-- window, e.g. the friends list), shaped like:
--
-- hl.workspace_rule({ workspace = "<steam-workspace>", persistent = true })
-- hl.window_rule({
--     name  = "steam-workspace",
--     match = { class = "<steam-main-class>" },
--     workspace = "<steam-workspace>",
-- })
-- hl.window_rule({
--     name  = "steam-secondary-float",
--     match = { class = "<steam-class>", title = "<secondary-title-regex>" },
--     float = true,
-- })

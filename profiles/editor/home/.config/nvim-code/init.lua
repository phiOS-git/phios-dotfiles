-- ~/.config/nvim-code/init.lua
--
-- phiOS — nvim-code, the IDE profile (run as `nvim-code`, NVIM_APPNAME
-- nvim-code). Shares options, keymaps, statusline, theme and the Chroma
-- integration with the other profiles through ~/.config/nvim-common, and
-- keeps its own plugins, lockfile and state.

local common = vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.normalize("~/.config"), "nvim-common")
vim.opt.runtimepath:prepend(common)

require("phi.options")
require("phi.keymaps")
require("phi_chroma")
require("phi.statusline")

-- Plugins: the shared list plus this profile's own. vim.pack asks before
-- installing anything, and nvim-pack-lock.json beside this file pins every
-- revision; updates are manual (`:lua vim.pack.update()`).
vim.pack.add(vim.list_extend(vim.list_extend({}, require("phi.plugins.common")), require("code.plugins")))

-- Theme last, so it restyles everything loaded above.
require("theme")

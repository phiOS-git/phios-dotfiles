-- ~/.config/nvim-notes/init.lua
--
-- phiOS — nvim-notes, the notes profile (run as `nvim-notes`, NVIM_APPNAME
-- nvim-notes). Shares options, keymaps, statusline, theme and the Chroma
-- integration with the other profiles through ~/.config/nvim-common, and
-- keeps its own plugins, lockfile and state.

local common = vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.normalize("~/.config"), "nvim-common")
vim.opt.runtimepath:prepend(common)

require("phi.options")
require("phi.keymaps")
require("phi_chroma")
require("phi.statusline")

-- Words added with zg go to a versioned list beside this file.
vim.opt.spellfile = vim.fs.joinpath(vim.fn.stdpath("config"), "spell", "user.utf-8.add")

-- Work from the vault root, so the language server, the attachments folder
-- and relative paths all agree on it.
require("notes.vault").enter()

-- Plugins: the shared list plus this profile's own. vim.pack asks before
-- installing anything, and nvim-pack-lock.json beside this file pins every
-- revision; updates are manual (`:lua vim.pack.update()`).
vim.pack.add(vim.list_extend(vim.list_extend({}, require("phi.plugins.common")), require("notes.plugins")))

require("phi.workbench").setup({ rename = false }) -- notes are renamed only through the LSP
require("notes.lsp").setup() -- markdown-oxide (lsp/markdown_oxide.lua)
require("notes.markdown").setup() -- render-markdown
require("notes.attachments").setup() -- img-clip
require("notes.media").setup() -- snacks image and zen, reading modes

-- Theme last, so it restyles everything loaded above.
require("theme")

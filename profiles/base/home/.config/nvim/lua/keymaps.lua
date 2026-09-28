-- ~/.config/nvim/lua/keymaps.lua
-- Mappings of the plugin-free profile only, on top of phi.keymaps. The
-- nvim-code and nvim-notes profiles map the same keys to their explorer,
-- file tabs and picker instead.

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts or {})
end

-- File explorer (netrw)
map("n", "<Leader>e", "<Cmd>Lexplore<CR>", { silent = true, desc = "Toggle file explorer" })

-- Tabs
map("n", "<Tab>", "<Cmd>tabnext<CR>", { silent = true, desc = "Next tab" })
map("n", "<S-Tab>", "<Cmd>tabprevious<CR>", { silent = true, desc = "Previous tab" })

-- Find files without a fuzzy-finder plugin: path+=** (phi.options) makes
-- :find search recursively and wildmode completes names as you type.
map("n", "<C-p>", ":find ", { desc = "Find file by name" })

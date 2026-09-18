-- ~/.config/nvim/lua/keymaps.lua
-- Key mappings. Built-in features only.

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts or {})
end

-- Save
map("n", "<Leader>w", ":w<CR>", { desc = "Save file" })

-- File explorer (netrw)
map("n", "<Leader>e", ":Lexplore<CR>", { silent = true, desc = "Toggle file explorer" })
map("n", "<C-h>", "<C-w>h", { desc = "Focus file explorer" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus editor" })

-- Tabs
map("n", "<Tab>", ":tabnext<CR>", { silent = true, desc = "Next tab" })
map("n", "<S-Tab>", ":tabprev<CR>", { silent = true, desc = "Previous tab" })

-- Search
map("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Find files without a fuzzy-finder plugin: path+=** (options.lua) makes
-- :find search recursively and wildmode completes names as you type.
map("n", "<C-p>", ":find ", { desc = "Find file by name" })
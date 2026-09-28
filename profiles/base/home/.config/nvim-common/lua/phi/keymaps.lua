-- ~/.config/nvim-common/lua/phi/keymaps.lua
-- Key mappings shared by every profile. Built-in features only; a profile
-- adds its own mappings on top, and may redefine these.

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts or {})
end

-- Save
map("n", "<Leader>w", "<Cmd>write<CR>", { desc = "Save file" })

-- Window focus: the side panel (explorer) and the editor
map("n", "<C-h>", "<C-w>h", { desc = "Focus window to the left" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus window to the right" })

-- Search
map("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

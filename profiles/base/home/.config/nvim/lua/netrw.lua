-- ~/.config/nvim/lua/netrw.lua
-- netrw as a persistent side file tree.
--
-- The tree is shown on the left in every tabpage, and files opened from
-- the tree get their own tab to the right. Netrw has no notion of a window
-- shared across tabpages, so "the explorer is not part of a tab" is
-- approximated the standard way: every tabpage carries its own copy of the
-- tree, backed by netrw's per-directory buffers (so they stay in sync).

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 20        -- tree width, percentage of the window
vim.g.netrw_browse_split = 3    -- <CR> on a file opens it in a new tab

local group = vim.api.nvim_create_augroup("PhiNetrw", { clear = true })

local function has_tree()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      return true
    end
  end
  return false
end

local function show_tree()
  if not has_tree() then
    vim.cmd("Lexplore")
  end
end

-- Show the tree on startup whatever the arguments are...
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = show_tree,
})

-- Show the tree in every tabpage entered afterwards, including the ones
-- netrw opens when a file is opened from the tree (netrw_browse_split = 3).
-- The check is deferred so it runs once the tab's layout has settled:
-- netrw opens such a file as `:tabedit`, and at TabEnter time the new
-- tab's window still holds a short-lived copy of the previous buffer —
-- even a netrw one — which `:edit` immediately replaces. A tick later the
-- real file buffer is there and the tree is added next to it.
vim.api.nvim_create_autocmd("TabEnter", {
  group = group,
  callback = function()
    vim.defer_fn(show_tree, 0)
  end,
})
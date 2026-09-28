-- ~/.config/nvim-common/lua/phi/reading.lua
--
-- Reading-mode helpers built on snacks.nvim's zen window. Shared so any
-- profile could call it, but only nvim-notes carries snacks and maps it.

local M = {}

-- The one active reading session, if any. snacks.zen is itself a global
-- singleton (only one zen window can be open at a time), so a single slot
-- here matches its own model rather than pretending sessions nest per window.
---@type {win: integer, buf: integer, conceallevel: integer, modifiable: boolean, zen: snacks.win?}?
local active

-- Puts the window and buffer back exactly as `M.toggle()` found them. Wired
-- as zen's own `on_close`, so this runs whether reading mode is turned off
-- from here, from `:q` on the zen window, or from zen's own toggle -- all
-- three close paths fire the same WinClosed handler inside snacks.
local function restore()
  if not active then
    return
  end
  local saved = active
  active = nil
  if vim.api.nvim_win_is_valid(saved.win) then
    vim.wo[saved.win].conceallevel = saved.conceallevel
  end
  if vim.api.nvim_buf_is_valid(saved.buf) then
    vim.bo[saved.buf].modifiable = saved.modifiable
  end
  if saved.zen and saved.zen:valid() then
    saved.zen:close()
  end
end

-- Reading mode: a centered zen window over the current buffer, concealed
-- and read-only. Toggling again, `:q`-ing the zen window or zen's own
-- toggle all restore the window's conceallevel and the buffer's modifiable
-- state exactly as they were.
function M.toggle()
  local ok, Snacks = pcall(require, "snacks")
  if not ok or not Snacks.zen then
    vim.notify("phi.reading: snacks.nvim is not available", vim.log.levels.WARN)
    return
  end

  if active then
    restore()
    return
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  active = {
    win = win,
    buf = buf,
    conceallevel = vim.wo[win].conceallevel,
    modifiable = vim.bo[buf].modifiable,
  }

  local opened, zen_win = pcall(Snacks.zen, { on_close = restore })
  active.zen = opened and zen_win or nil

  -- Conceal on whichever window is actually visible: zen's own floating
  -- window when it opened one, the original window otherwise (headless, or
  -- a terminal with no UI to float a window in).
  local target = (active.zen and active.zen.win) or win
  vim.wo[target].conceallevel = 2
  vim.bo[buf].modifiable = false
end

-- Per-window scrolloff, so the cursor line stays centered while writing.
---@type table<integer, integer>
local scrolloff = {}

-- Typewriter scrolling: toggle the window's scrolloff between 999 (cursor
-- pinned to the middle line) and whatever it was before.
function M.typewriter()
  local win = vim.api.nvim_get_current_win()
  if scrolloff[win] then
    vim.wo[win].scrolloff = scrolloff[win]
    scrolloff[win] = nil
  else
    scrolloff[win] = vim.wo[win].scrolloff
    vim.wo[win].scrolloff = 999
  end
end

return M

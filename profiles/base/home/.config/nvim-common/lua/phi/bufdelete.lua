-- ~/.config/nvim-common/lua/phi/bufdelete.lua
-- Deletes a file buffer without closing its windows: every window showing it
-- is moved to another buffer first, so the explorer and any splits survive.

local M = {}

local function resolve(bufnr)
  if bufnr == nil or bufnr == 0 then
    return vim.api.nvim_get_current_buf()
  end
  return bufnr
end

local function next_listed(target)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= target
        and vim.api.nvim_buf_is_valid(b)
        and vim.bo[b].buflisted
        and vim.bo[b].buftype == ""
    then
      return b
    end
  end
  return nil
end

-- move one window off the buffer being deleted: alternate buffer, else the
-- next listed file buffer, else a fresh empty one
local function vacate(win, target)
  vim.api.nvim_win_call(win, function()
    local alt = vim.fn.bufnr("#")
    if alt ~= -1 and alt ~= target and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
      vim.api.nvim_win_set_buf(win, alt)
      return
    end

    local fallback = next_listed(target)
    if fallback then
      vim.api.nvim_win_set_buf(win, fallback)
    else
      vim.cmd.enew()
    end
  end)
end

function M.delete(bufnr, force)
  bufnr = resolve(bufnr)
  force = force or false

  if vim.bo[bufnr].modified and not force then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    if name == "" then
      name = "[No Name]"
    end
    vim.notify("Unsaved changes in " .. name .. "; save first or use force", vim.log.levels.WARN)
    return false
  end

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vacate(win, bufnr)
      end
    end
  end

  local ok = pcall(vim.cmd.bdelete, { args = { bufnr }, bang = force })
  return ok
end

return M

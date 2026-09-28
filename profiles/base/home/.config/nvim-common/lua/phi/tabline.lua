-- ~/.config/nvim-common/lua/phi/tabline.lua
-- Renders the tabline: one open file is one tab. Labels are disambiguated by
-- parent directory when two listed buffers share a file name, and clicking a
-- tab switches to its buffer, routing around a docked file explorer.

local M = {}

-- find the docked explorer window in a tabpage, if one is open there
local function explorer_win(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "NvimTree" then
      return win
    end
  end
  return nil
end

-- listed, valid, normal-file buffers, in buffer-number order
local function listed_buffers()
  local bufs = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].buftype == "" then
      table.insert(bufs, b)
    end
  end
  table.sort(bufs)
  return bufs
end

local function tail(name)
  if name == "" then
    return "[No Name]"
  end
  return vim.fn.fnamemodify(name, ":t")
end

-- one label per buffer, parent directory appended only where the tail alone
-- would be ambiguous, modified marker appended last
local function labels_for(bufs)
  local tail_count = {}
  for _, b in ipairs(bufs) do
    local t = tail(vim.api.nvim_buf_get_name(b))
    tail_count[t] = (tail_count[t] or 0) + 1
  end

  local label = {}
  for _, b in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(b)
    local t = tail(name)
    local text = t
    if tail_count[t] > 1 and name ~= "" then
      text = string.format("%s (%s)", t, vim.fn.fnamemodify(name, ":h:t"))
    end
    if vim.bo[b].modified then
      text = text .. " +"
    end
    label[b] = text
  end
  return label
end

-- literal `%` in a name would otherwise be read as a tabline format specifier
local function escape(s)
  return (s:gsub("%%", "%%%%"))
end

function M.render()
  local out = {}

  local tree_win = explorer_win(0)
  if tree_win then
    local width = vim.api.nvim_win_get_width(tree_win)
    table.insert(out, "%#TabLineFill#" .. string.rep(" ", width + 1))
  end

  local bufs = listed_buffers()
  local label = labels_for(bufs)
  local current = vim.api.nvim_get_current_buf()
  local current_is_listed = vim.tbl_contains(bufs, current)

  for _, b in ipairs(bufs) do
    local hl = (current_is_listed and b == current) and "%#TabLineSel#" or "%#TabLine#"
    table.insert(out, string.format("%%%d@v:lua.phi_tabline_click@%s %s %%X", b, hl, escape(label[b])))
  end

  table.insert(out, "%#TabLineFill#%=")

  local total = vim.fn.tabpagenr("$")
  if total > 1 then
    table.insert(out, string.format("%%#TabLineFill# %d/%d ", vim.fn.tabpagenr(), total))
  end

  return table.concat(out)
end

-- tabline click handler: v:lua.phi_tabline_click(minwid, clicks, button, mods)
_G.phi_tabline_click = function(bufnr, _clicks, button, _mods)
  if button ~= "l" then
    return
  end

  if vim.bo[vim.api.nvim_get_current_buf()].filetype == "NvimTree" then
    vim.cmd.wincmd("p")
    if vim.bo[vim.api.nvim_get_current_buf()].filetype == "NvimTree" then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "NvimTree" then
          vim.api.nvim_set_current_win(win)
          break
        end
      end
    end
  end

  vim.api.nvim_set_current_buf(bufnr)
end

function M.setup()
  vim.o.showtabline = 2
  vim.o.tabline = "%!v:lua.require'phi.tabline'.render()"

  local group = vim.api.nvim_create_augroup("PhiTabline", { clear = true })

  vim.api.nvim_create_autocmd({
    "WinResized", "BufAdd", "BufModifiedSet", "BufEnter",
    "TabEnter", "TabNew", "TabClosed", "FileType",
  }, {
    group = group,
    callback = function()
      vim.cmd.redrawtabline()
    end,
  })

  -- the buffer list only reflects the change after these fire
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function()
      vim.schedule(function()
        vim.cmd.redrawtabline()
      end)
    end,
  })
end

return M

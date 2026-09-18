-- ~/.config/nvim/lua/statusline.lua
-- Minimal statusline built from built-in statusline items — no plugin.
--
-- No colours are defined here: the statusline only uses the standard
-- StatusLine / StatusLineNC groups, which the generated theme restyles.

local mode_labels = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  R = "REPLACE",
  t = "TERMINAL",
}

function _G.statusline_mode()
  local m = vim.api.nvim_get_mode().mode
  return " " .. (mode_labels[m] or m:upper()) .. " "
end

vim.opt.statusline = "%{v:lua.statusline_mode()}%< %f%m%r %= %{&filetype} %l:%c %p%%"
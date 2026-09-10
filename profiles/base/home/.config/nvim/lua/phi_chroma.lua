-- ~/.config/nvim/lua/phi_chroma.lua
--
-- phiOS — Neovim → Chroma keyboard "neovim" integration (settings-overhaul
-- batch G). On every mode change this sends the current mode's first letter
-- to phi-shell's `chroma` IPC handler; Services/Chroma.qml maps that letter
-- to a design-token colour and tints the keyboard.
--
-- No colour lives here — only the mode letter crosses the boundary, so this
-- file carries no literal (I-05). Plain Lua, no plugin manager (the nvim
-- config is deliberately minimal). Non-blocking: vim.system / jobstart
-- spawn and never wait, so nothing here can stall the editor.
--
-- Safe to require unconditionally: on a host with no Chroma keyboard the
-- shell's handler is a no-op, and if `qs` is absent this sets up nothing.

if vim.fn.executable("qs") ~= 1 then
  return
end

local qs_config = vim.fn.expand("~/.config/quickshell/phi")
local last = nil

local function spawn(argv)
  if vim.system then
    vim.system(argv, { text = true })
  else
    vim.fn.jobstart(argv, { detach = true })
  end
end

local function send(mode)
  local m = (mode or "n"):sub(1, 1)
  if m == last then
    return
  end
  last = m
  spawn({ "qs", "-p", qs_config, "ipc", "call", "chroma", "nvimMode", m })
end

local group = vim.api.nvim_create_augroup("PhiChroma", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  callback = function()
    -- new_mode is the mode being entered, e.g. "n", "i", "v", "V", "R", "c".
    send(vim.v.event.new_mode)
  end,
})

-- Leave the keyboard on the base colour when nvim is backgrounded or quits.
vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
  group = group,
  callback = function()
    send("n")
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = group,
  callback = function()
    last = nil
    send(vim.api.nvim_get_mode().mode)
  end,
})

-- ~/.config/nvim-notes/lua/notes/vault.lua
--
-- The vault is the directory holding a `.moxide.toml`: the root of the
-- markdown-oxide workspace, of the attachments folder and of nvim-notes'
-- working directory. Nested folders are allowed; the nearest marker upward
-- wins.

local M = {}

M.marker = ".moxide.toml"

-- Vault root containing `path` (a file, a directory, or a note not yet
-- written), or nil outside any vault. Defaults to the current buffer, then
-- the working directory.
function M.root(path)
  if not path or path == "" then
    path = vim.api.nvim_buf_get_name(0)
  end
  if path == "" then
    path = vim.fn.getcwd()
  end
  return vim.fs.root(vim.fs.abspath(path), M.marker)
end

-- Folder every attachment goes to, or nil outside a vault.
function M.attachments_dir(path)
  local root = M.root(path)
  return root and vim.fs.joinpath(root, "attachments") or nil
end

-- Change to the vault root of the first file argument, or of the working
-- directory when there is none. Done at startup, before any buffer loads, so
-- file arguments are already absolute in Neovim's buffer list and relative
-- names on the command line keep working.
function M.enter()
  local root = M.root(vim.fn.argv(0) --[[@as string]] ~= "" and vim.fn.argv(0) or vim.fn.getcwd())
  if root and root ~= vim.fn.getcwd() then
    vim.fn.chdir(root)
  end
end

return M

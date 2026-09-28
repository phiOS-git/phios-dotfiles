-- ~/.config/nvim-code/lua/code/plugins.lua
-- vim.pack specs of the plugins only nvim-code uses. The shared ones are in
-- nvim-common/lua/phi/plugins/common.lua.

local range = vim.version.range
local function gh(repo)
  return "https://github.com/" .. repo
end

return {
  -- Parsers and queries; the parsers themselves are installed by hand (:TSInstall).
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("saghen/blink.cmp"), version = range("^1.10") }, -- completion
  { src = gh("stevearc/conform.nvim"), version = range("^9.1") }, -- formatting
}

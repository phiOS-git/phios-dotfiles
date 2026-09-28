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
  { src = gh("MagicDuck/grug-far.nvim"), version = range("^1.6") }, -- project search and replace
  { src = gh("jake-stewart/multicursor.nvim"), version = "1.0" }, -- release branch; no tags
  -- Debugger. Tracks master: its last tag predates the session listeners
  -- nvim-dap-view needs.
  { src = gh("mfussenegger/nvim-dap"), version = "master" },
  { src = gh("igorlfs/nvim-dap-view"), version = range("^1.2") }, -- debugger UI
  -- TODO: minuet-ai.nvim (AI inline completion, docs/phios-nvim.md NV-07),
  -- once the phi agent broker it talks to is in place.
}

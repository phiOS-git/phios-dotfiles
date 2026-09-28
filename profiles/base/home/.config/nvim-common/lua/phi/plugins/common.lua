-- ~/.config/nvim-common/lua/phi/plugins/common.lua
--
-- vim.pack specs of the plugins shared by nvim-code and nvim-notes. Each
-- profile passes this list to vim.pack.add() together with its own, so an
-- update of a shared plugin has to be run in both profiles, and both
-- lockfiles committed.
--
-- `version` is a semver range where the project tags releases, or a branch
-- where it does not; the exact revision is pinned by each profile's
-- nvim-pack-lock.json either way.

local range = vim.version.range
local function gh(repo)
  return "https://github.com/" .. repo
end

return {
  { src = gh("nvim-tree/nvim-tree.lua"), version = range("^1.18") }, -- explorer
  { src = gh("ibhagwan/fzf-lua"), version = "main" }, -- picker and palette; no release tags
  { src = gh("folke/which-key.nvim"), version = range("^3.17") }, -- shortcut discovery
  { src = gh("lewis6991/gitsigns.nvim"), version = range("^2.1") }, -- git signs and hunks
}

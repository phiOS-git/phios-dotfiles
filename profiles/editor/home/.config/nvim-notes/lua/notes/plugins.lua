-- ~/.config/nvim-notes/lua/notes/plugins.lua
-- vim.pack specs of the plugins only nvim-notes uses. The shared ones are in
-- nvim-common/lua/phi/plugins/common.lua.

local range = vim.version.range
local function gh(repo)
  return "https://github.com/" .. repo
end

return {
  -- Parsers and queries; the parsers themselves are installed by hand (:TSInstall).
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("MeanderingProgrammer/render-markdown.nvim"), version = range("^8.14") }, -- in-buffer rendering
  { src = gh("HakonHarnes/img-clip.nvim"), version = range("^0.6") }, -- attachments
  { src = gh("folke/snacks.nvim"), version = range("^2.31") }, -- image and zen modules only
}

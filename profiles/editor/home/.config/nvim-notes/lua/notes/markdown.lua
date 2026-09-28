-- ~/.config/nvim-notes/lua/notes/markdown.lua
--
-- render-markdown.nvim: renders markdown in place instead of leaving raw
-- syntax on screen. LaTeX stays off here; notes.media renders formulas as
-- images instead. Anti-conceal keeps the line under the cursor showing its
-- raw text, so it stays editable without a manual toggle.

local M = {}

function M.setup()
  require("render-markdown").setup({
    file_types = { "markdown" },
    latex = { enabled = false },
    anti_conceal = { enabled = true },
  })
end

return M

-- ~/.config/nvim-code/lua/code/treesitter.lua
-- Highlighting and folds from Neovim's built-in treesitter, using the
-- parsers and queries nvim-treesitter (branch main) ships. Parsers are
-- installed by hand with :TSInstall; nothing here installs one.
local M = {}

function M.setup()
  -- phi-shell's QML files get filetype "qml", but nvim-treesitter's grammar
  -- and query directory for it are named "qmljs"; link the two explicitly,
  -- since nvim-treesitter main does not.
  vim.treesitter.language.register("qmljs", "qml")

  local group = vim.api.nvim_create_augroup("PhiTreesitter", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    desc = "Start treesitter highlighting and folds where a parser is installed",
    callback = function()
      -- pcall: silently does nothing when the buffer's parser was never
      -- installed, rather than erroring on every unparsed filetype.
      if pcall(vim.treesitter.start) then
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end
    end,
  })
end

return M

-- ~/.config/nvim-notes/after/ftplugin/markdown.lua
--
-- In after/ so this loads after, and overrides, the runtime's own markdown
-- ftplugin (which sets its own 'formatoptions' and friends); a plain
-- ftplugin/markdown.lua would run first and lose those settings to it.

vim.opt_local.spell = true
vim.opt_local.spelllang = "it,en"
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.conceallevel = 2

-- Heading folds, only once a parser is actually attached: without one,
-- foldexpr would just error on every fold recalculation.
if pcall(vim.treesitter.start) then
  vim.opt_local.foldmethod = "expr"
  vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

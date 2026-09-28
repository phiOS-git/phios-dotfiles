-- ~/.config/nvim-code/lsp/gopls.lua
-- gopls config, from pacman's gopls.
return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
}

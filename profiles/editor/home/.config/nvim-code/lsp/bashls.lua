-- ~/.config/nvim-code/lsp/bashls.lua
-- bash-language-server config, from pacman's bash-language-server. It picks
-- up shellcheck on its own whenever shellcheck is on PATH.
return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
}

-- ~/.config/nvim-code/lsp/qmlls.lua
-- qmlls config, for phi-shell's QML. Arch's qt6-declarative package puts the
-- binary outside PATH, so it is called by absolute path.
return {
  cmd = { "/usr/lib/qt6/bin/qmlls" },
  filetypes = { "qml", "qmljs" },
  root_markers = { ".qmlls.ini", ".git" },
}

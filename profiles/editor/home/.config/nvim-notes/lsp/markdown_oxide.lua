-- ~/.config/nvim-notes/lsp/markdown_oxide.lua
--
-- markdown-oxide: the note-graph language server (declared in
-- profiles/editor/packages.txt). It needs dynamic file-watch registration
-- to notice notes created or renamed outside the editor. Neovim only turns
-- that capability on by default on Darwin and Windows, so it is forced here
-- for every host, including the Arch Linux machines this profile runs on.
local capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
  workspace = {
    didChangeWatchedFiles = {
      dynamicRegistration = true,
    },
  },
})

return {
  cmd = { "markdown-oxide" },
  filetypes = { "markdown" },
  root_markers = { ".moxide.toml" },
  capabilities = capabilities,
}

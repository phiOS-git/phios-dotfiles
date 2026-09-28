-- ~/.config/nvim-code/lua/code/lsp.lua
-- Native LSP: enables the servers declared in lsp/*.lua, diagnostics
-- display, and the mappings Neovim 0.12's own LSP defaults (K, grn, gra,
-- grr, gri, grt, gO) don't already cover.
local M = {}

function M.setup()
  vim.lsp.enable({ "lua_ls", "gopls", "bashls", "qmlls" })

  vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = "rounded" },
  })

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  vim.keymap.set("n", "<Leader>cq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

  -- which-key is loaded by phi.workbench; pcall in case load order ever changes.
  pcall(function()
    require("which-key").add({ { "<Leader>c", group = "code" } })
  end)
end

return M

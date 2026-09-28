-- ~/.config/nvim-notes/lua/notes/lsp.lua
--
-- Wires markdown-oxide (lsp/markdown_oxide.lua) into the buffer. This
-- profile carries no completion or codelens plugin, so both are turned on
-- through the built-ins: typing `[[` plus part of an alias completes the
-- link, and inlay hints show block transclusions inline.

local M = {}

function M.setup()
  vim.lsp.enable("markdown_oxide")

  -- menuone/noselect/popup/fuzzy is what makes the built-in completion
  -- behave like a plugin's: a menu on the first match, nothing inserted
  -- until picked, fuzzy filtering on the typed alias.
  vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

  local group = vim.api.nvim_create_augroup("PhiNotesLsp", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client or client.name ~= "markdown_oxide" then
        return
      end
      local bufnr = args.buf

      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

      -- markdown-oxide reports things like backlink counts through code
      -- lenses; the provider already re-requests on its own when this
      -- buffer's text changes, but not when a *different* note changes
      -- one of its lens counts, so re-attaching on these events still
      -- earns a fresh request. enable(true) alone is a no-op once already
      -- enabled, hence the toggle.
      if client:supports_method("textDocument/codeLens", bufnr) then
        vim.lsp.codelens.enable(true, { bufnr = bufnr })
        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
          group = group,
          buffer = bufnr,
          desc = "Refresh markdown-oxide code lenses",
          callback = function()
            vim.lsp.codelens.enable(false, { bufnr = bufnr })
            vim.lsp.codelens.enable(true, { bufnr = bufnr })
          end,
        })
      end

      -- K (hover), grr (references/backlinks), grn (rename, updates links)
      -- and gra (code action: create note) are already the Neovim defaults.
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
        buffer = bufnr,
        desc = "Go to note / definition",
      })
    end,
  })

  vim.diagnostic.config({ virtual_text = true, severity_sort = true })
end

return M

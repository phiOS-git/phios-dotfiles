-- ~/.config/nvim-code/lua/code/completion.lua
-- blink.cmp: completion sources, snippets, and the capabilities every
-- language server needs advertised to it so LSP-driven completion works.
local M = {}

function M.setup()
  require("blink.cmp").setup({
    fuzzy = {
      -- Lua implementation only: nothing may fetch a prebuilt binary at
      -- runtime, and pacman does not package one.
      implementation = "lua",
      prebuilt_binaries = { download = false },
    },
    sources = {
      -- TODO: minuet source, manual trigger (docs/phios-nvim.md NV-07), once the phi agent broker exists.
      default = { "lsp", "path", "buffer", "snippets" },
      providers = {
        snippets = {
          opts = {
            -- Shared across nvim-code and nvim-notes; see nvim-common/snippets.
            search_paths = {
              vim.fs.joinpath(vim.env.XDG_CONFIG_HOME or vim.fs.normalize("~/.config"), "nvim-common", "snippets"),
            },
          },
        },
      },
    },
    snippets = { preset = "default" }, -- vim.snippet, Neovim's own engine
    keymap = { preset = "default" },
  })

  -- Every lsp/*.lua server gets blink's completion capabilities; resolution
  -- of vim.lsp.config is lazy, so this can run before or after code.lsp's
  -- vim.lsp.enable() without losing the merge.
  vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
end

return M

-- ~/.config/nvim-code/lua/code/format.lua
-- conform.nvim: one formatter per filetype, all from pacman. Go carries no
-- entry and falls back to gopls's own formatting.
local M = {}

function M.setup()
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      qml = { "qmlformat" },
    },
    formatters = {
      -- Arch's qt6-declarative package puts qmlformat outside PATH; keep
      -- conform's default args, only the command changes.
      qmlformat = { command = "/usr/lib/qt6/bin/qmlformat" },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  })

  -- conform.format() reads the visual selection as the range on its own, so
  -- one mapping covers both a full-buffer and a range format.
  vim.keymap.set({ "n", "v" }, "<Leader>cf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format buffer" })
end

return M

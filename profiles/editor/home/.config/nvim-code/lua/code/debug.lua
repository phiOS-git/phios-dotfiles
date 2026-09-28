-- ~/.config/nvim-code/lua/code/debug.lua
--
-- Go debugging via nvim-dap talking to delve, with nvim-dap-view as the UI.
-- Bound under <leader>d plus the usual F-key step controls.

local M = {}

function M.setup()
  local dap = require("dap")

  dap.adapters.go = {
    type = "server",
    port = "${port}",
    executable = {
      command = "dlv",
      args = { "dap", "-l", "127.0.0.1:${port}" },
    },
  }

  dap.configurations.go = {
    {
      type = "go",
      name = "Debug file",
      request = "launch",
      program = "${file}",
    },
    {
      type = "go",
      name = "Debug package",
      request = "launch",
      program = "${fileDirname}",
    },
    {
      type = "go",
      name = "Debug package tests",
      request = "launch",
      mode = "test",
      program = "${fileDirname}",
    },
    {
      type = "go",
      name = "Debug test by name",
      request = "launch",
      mode = "test",
      program = "${fileDirname}",
      args = function()
        return { "-test.run", vim.fn.input("Test regex: ") }
      end,
    },
  }

  -- nvim-dap-view has its own auto-open/auto-close option, so no manual
  -- dap.listeners wiring is needed to show it around a session.
  require("dap-view").setup({ auto_toggle = true })

  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })

  vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
  vim.keymap.set("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "Conditional breakpoint" })
  vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue/start debugging" })
  vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
  vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
  vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
  vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
  vim.keymap.set("n", "<leader>dv", function()
    require("dap-view").toggle()
  end, { desc = "Toggle dap-view" })
  vim.keymap.set("n", "<leader>dr", dap.run_last, { desc = "Run last" })

  vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue/start debugging" })
  vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
  vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
  vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })

  pcall(function()
    require("which-key").add({
      { "<leader>d", group = "debug" },
    })
  end)
end

return M

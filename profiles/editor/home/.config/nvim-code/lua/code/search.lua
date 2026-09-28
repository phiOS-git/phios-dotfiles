-- ~/.config/nvim-code/lua/code/search.lua
--
-- Project-wide search and replace via grug-far, bound under <leader>s. Three
-- entry points cover the common starting points (a blank prompt, the word
-- under the cursor, the current file) without requiring the picker for
-- everyday find-and-replace.

local M = {}

function M.setup()
  local grug_far = require("grug-far")

  grug_far.setup({ engine = "ripgrep" })

  vim.keymap.set("n", "<leader>sr", function()
    grug_far.open()
  end, { desc = "Search and replace in project" })

  vim.keymap.set("x", "<leader>sr", function()
    grug_far.with_visual_selection()
  end, { desc = "Search and replace in project" })

  vim.keymap.set("n", "<leader>sw", function()
    grug_far.open({ prefills = { search = vim.fn.expand("<cword>") } })
  end, { desc = "Search and replace word under cursor" })

  vim.keymap.set("n", "<leader>sf", function()
    grug_far.open({ prefills = { paths = vim.fn.expand("%") } })
  end, { desc = "Search and replace in current file" })

  pcall(function()
    require("which-key").add({
      { "<leader>s", group = "search/replace", mode = { "n", "x" } },
    })
  end)
end

return M

-- ~/.config/nvim-code/lua/code/multicursor.lua
--
-- Multiple cursors via multicursor.nvim, bound under <leader>m plus the
-- mouse. The keymap layer only intercepts <Esc> while cursors exist, so
-- normal <Esc> behaviour is untouched the rest of the time.

local M = {}

function M.setup()
  local mc = require("multicursor-nvim")

  mc.setup()

  vim.keymap.set({ "n", "x" }, "<leader>mj", function()
    mc.lineAddCursor(1)
  end, { desc = "Add cursor on the line below" })

  vim.keymap.set({ "n", "x" }, "<leader>mk", function()
    mc.lineAddCursor(-1)
  end, { desc = "Add cursor on the line above" })

  vim.keymap.set({ "n", "x" }, "<leader>mn", function()
    mc.matchAddCursor(1)
  end, { desc = "Add cursor at next match" })

  vim.keymap.set({ "n", "x" }, "<leader>mN", function()
    mc.matchAddCursor(-1)
  end, { desc = "Add cursor at previous match" })

  vim.keymap.set({ "n", "x" }, "<leader>ms", function()
    mc.matchSkipCursor(1)
  end, { desc = "Skip next match" })

  vim.keymap.set({ "n", "x" }, "<leader>ma", mc.matchAllAddCursors, { desc = "Add cursors at all matches" })

  vim.keymap.set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Add/remove cursor with the mouse" })
  vim.keymap.set("n", "<C-LeftDrag>", mc.handleMouseDrag, { desc = "Add cursors by dragging the mouse" })
  vim.keymap.set("n", "<C-LeftRelease>", mc.handleMouseRelease, { desc = "Finish adding cursors with the mouse" })

  -- Layer mappings only apply while multiple cursors exist, so this is the
  -- one place <Esc> is safe to repurpose: clear the cursors, or re-enable
  -- them first if they were disabled.
  mc.addKeymapLayer(function(layerSet)
    layerSet("n", "<Esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      else
        mc.clearCursors()
      end
    end, { desc = "Clear cursors (or re-enable if disabled)" })
  end)

  -- Only link to highlight groups that already exist; multicursor.nvim's
  -- README pairs each of these with one of them.
  local function link_highlights()
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end

  link_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = link_highlights, desc = "Re-link multicursor highlights" })

  pcall(function()
    require("which-key").add({
      { "<leader>m", group = "multicursor", mode = { "n", "x" } },
    })
  end)
end

return M

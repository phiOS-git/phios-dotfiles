-- ~/.config/nvim-notes/lua/notes/attachments.lua
--
-- img-clip.nvim: pastes or drags an image straight into the current vault's
-- attachments folder and links it Obsidian-style, by file name. wl-clipboard
-- supplies the clipboard image; img-clip detects it on its own.

local M = {}

function M.setup()
  require("img-clip").setup({
    default = {
      -- An absolute path works as-is; img-clip only joins it under the
      -- current file when relative_to_current_file is set, which it is
      -- not here. Outside a vault there is no attachments dir to resolve,
      -- so fall back to a plain relative folder under the cwd.
      dir_path = function()
        return require("notes.vault").attachments_dir() or "attachments"
      end,
      file_name = "%Y%m%d-%H%M%S",
      prompt_for_file_name = false,
      use_absolute_path = false,
      relative_to_current_file = false,
      -- Without this, a dragged-in path is only linked where it already
      -- sits; img-clip's own default leaves it there. Copying is what
      -- makes "dropped into the vault" true for a file dragged in from
      -- outside it.
      copy_images = true,
      drag_and_drop = {
        enabled = true,
        insert_mode = true, -- image dropped into the kitty terminal, bracketed-pasted in
      },
    },
    filetypes = {
      markdown = {
        template = "![[$FILE_NAME]]",
      },
    },
  })

  vim.keymap.set("n", "<leader>np", "<cmd>PasteImage<cr>", { desc = "Paste image from clipboard" })

  pcall(function()
    require("which-key").add({
      { "<leader>n", group = "notes" },
    })
  end)
end

return M

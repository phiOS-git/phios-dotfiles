-- ~/.config/nvim-common/lua/phi/workbench.lua
-- Wires the editing workbench: file explorer, fuzzy finder, key hint popup
-- and git gutter, plus the buffer/tabpage navigation that sits on top of
-- them. Shared by every profile that ships these plugins.

local M = {}

-- true when the current window is the docked explorer
local function is_explorer_win()
  return vim.bo.filetype == "NvimTree"
end

local function setup_nvim_tree(rename)
  -- default mappings, minus the rename family: in the notes vault, files are
  -- renamed only through the language server so links get updated with them
  local function on_attach_no_rename(bufnr)
    require("nvim-tree.api").map.on_attach.default(bufnr)
    for _, lhs in ipairs({ "r", "e", "u", "<C-r>" }) do
      vim.keymap.del("n", lhs, { buffer = bufnr })
    end
  end

  require("nvim-tree").setup({
    disable_netrw = true,
    -- disable_netrw alone already hijacks directory buffers (netrw never
    -- loads to contest them); hijack_netrw would only add an unconditional
    -- "clear netrw's autocmd group" call that errors because the group was
    -- never created, since netrw itself never loaded
    hijack_netrw = false,
    view = {
      side = "left",
      width = 30,
    },
    -- one explorer, kept in sync across every tabpage rather than one per tab
    tab = {
      sync = {
        open = true,
        close = true,
      },
    },
    update_focused_file = {
      enable = true,
    },
    renderer = {
      icons = {
        show = {
          file = false,
          git = false,
          folder = true,
          folder_arrow = true,
        },
      },
    },
    -- omitted (falls back to nvim-tree's built-in "default") unless the
    -- rename family needs stripping
    on_attach = (not rename) and on_attach_no_rename or nil,
  })
end

local function setup_fzf_lua()
  require("fzf-lua").setup({
    fzf_colors = true, -- derive fzf's own colours from highlight groups
    defaults = {
      file_icons = false,
      git_icons = false,
    },
    -- nested picker groups (git.*) don't inherit `defaults` above, they need
    -- their own icon flags turned off explicitly
    git = {
      status = {
        file_icons = false,
        git_icons = false,
      },
    },
  })
end

local function setup_which_key()
  require("which-key").setup({
    icons = { mappings = false },
  })
  require("which-key").add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>t", group = "tabpage" },
  })
end

local function setup_gitsigns()
  require("gitsigns").setup({
    signcolumn = true, -- hunk signs in the margin
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function gmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      gmap("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next hunk")

      gmap("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Previous hunk")

      gmap("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
      gmap("v", "<leader>gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")

      gmap("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
      gmap("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")

      gmap("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
      gmap("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame line")
    end,
  })
end

local function setup_keymaps()
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
  end

  -- Explorer
  map("n", "<leader>e", function()
    require("nvim-tree.api").tree.toggle()
  end, "Toggle explorer")
  map("n", "<leader>E", function()
    require("nvim-tree.api").tree.find_file({ open = true, focus = true })
  end, "Reveal current file in explorer")

  -- Buffers: skip when the explorer is focused, it has no buffer cycle
  map("n", "<Tab>", function()
    if is_explorer_win() then
      return
    end
    vim.cmd.bnext()
  end, "Next buffer")
  map("n", "<S-Tab>", function()
    if is_explorer_win() then
      return
    end
    vim.cmd.bprevious()
  end, "Previous buffer")
  map("n", "<leader>x", function()
    require("phi.bufdelete").delete(0, false)
  end, "Close file")
  map("n", "<leader>X", function()
    require("phi.bufdelete").delete(0, true)
  end, "Force close file")

  -- Tabpages
  map("n", "<leader>tn", "<Cmd>tabnew<CR>", "New tabpage")
  map("n", "<leader>tc", "<Cmd>tabclose<CR>", "Close tabpage")

  -- Find
  map("n", "<C-p>", function()
    require("fzf-lua").files()
  end, "Find files")
  map("n", "<leader>ff", function()
    require("fzf-lua").files()
  end, "Find files")
  map("n", "<leader>fg", function()
    require("fzf-lua").live_grep()
  end, "Live grep")
  map("n", "<leader>fb", function()
    require("fzf-lua").buffers()
  end, "Find buffers")
  map("n", "<leader>fc", function()
    require("fzf-lua").commands()
  end, "Find commands")
  map("n", "<leader>fs", function()
    require("fzf-lua").lsp_document_symbols()
  end, "Document symbols")
  map("n", "<leader>fS", function()
    require("fzf-lua").lsp_live_workspace_symbols()
  end, "Workspace symbols")
  map("n", "<leader>fd", function()
    require("fzf-lua").diagnostics_document()
  end, "Document diagnostics")
  map("n", "<leader>fD", function()
    require("fzf-lua").diagnostics_workspace()
  end, "Workspace diagnostics")
  map("n", "<leader>fk", function()
    require("fzf-lua").keymaps()
  end, "Find keymaps")
  map("n", "<leader>fG", function()
    require("fzf-lua").git_status()
  end, "Git status")
  map("n", "<leader>fr", function()
    require("fzf-lua").resume()
  end, "Resume last picker")
end

function M.setup(opts)
  opts = opts or {}
  local rename = opts.rename
  if rename == nil then
    rename = true
  end

  setup_nvim_tree(rename)
  setup_fzf_lua()
  setup_which_key()
  setup_gitsigns()
  setup_keymaps()

  require("phi.tabline").setup()
end

return M

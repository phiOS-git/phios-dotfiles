-- ~/.config/nvim/lua/options.lua
-- Core editor options. Built-in Neovim behaviour only — no plugins.

-- Syntax highlighting and filetype plugins (built-in, not external)
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- stable gutter, no horizontal shift

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Text display
opt.wrap = false
opt.cursorline = true
opt.termguicolors = true

-- Search
opt.ignorecase = true -- case-insensitive search...
opt.smartcase = true  -- ...unless the pattern contains a capital
opt.incsearch = true
opt.hlsearch = true

-- Buffers and files
opt.hidden = true    -- edited buffers can stay open in the background
opt.autoread = true  -- pick up file changes from disk

-- Statusline and command line
opt.showmode = false -- the mode is shown by the statusline instead
opt.laststatus = 2
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- Make :find / gf / ** usable for file navigation without a plugin
opt.path:append("**")

-- Leader key
vim.g.mapleader = " "
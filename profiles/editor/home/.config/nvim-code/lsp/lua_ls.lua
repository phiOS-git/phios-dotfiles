-- ~/.config/nvim-code/lsp/lua_ls.lua
-- lua-language-server config, from pacman's lua-language-server. Points the
-- workspace library at Neovim's own runtime, so `vim` is known everywhere
-- config files (this repo included) are edited.
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}

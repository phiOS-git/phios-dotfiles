# editor

`zotac` and `razer`. The two Neovim profiles that carry plugins, run as
`nvim-code` (the IDE) and `nvim-notes` (the notes vault), each through a
wrapper in `~/.local/bin` that sets `NVIM_APPNAME`. Plain `nvim` — the
plugin-free editor behind `$EDITOR`, and the only one on `mini` — stays in
`base`, together with `~/.config/nvim-common`, the layer all three share:
options, keymaps, statusline, the rendered theme, the Chroma integration and
the `phi.*` modules.

Plugins are managed by Neovim's built-in `vim.pack`, never by another plugin
manager. Each profile's `nvim-pack-lock.json` is versioned here and pins every
plugin revision; `vim.pack` asks before installing anything, and updates are
only ever run by hand (`:lua vim.pack.update()`), then the lockfile is
committed. Language servers, formatters, the debugger and every other external
tool come from pacman through `packages.txt` — nothing is downloaded by a
plugin.

The full design is `docs/phios-nvim.md` in the workspace.

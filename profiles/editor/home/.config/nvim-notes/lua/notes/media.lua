-- ~/.config/nvim-notes/lua/notes/media.lua
--
-- snacks.nvim, restricted to its image and zen modules: inline images, PDF
-- previews and LaTeX math rendered in the buffer over the kitty graphics
-- protocol, and a centered reading window. Every other snacks module (the
-- picker, dashboard, notifier, explorer, ...) stays off -- this profile
-- already has fzf-lua, nvim-tree and its own statusline for that, and
-- snacks.setup() only turns on the modules a config table is passed for.

local vault = require("notes.vault")

-- Where an embed's target actually lives. `doc.lua` calls this for every
-- image src it finds -- including remote ones -- before falling back to its
-- own relative-path resolution, so it is the only hook this module has to
-- decide what happens to a URL.
--   - a bare name, from `![[x.png]]` or `![](x.png)`, is a vault attachment;
--   - a relative path with a directory (`![](sub/x.png)`) is left to
--     snacks' own resolution, which checks it against the note's directory;
--   - a remote src (`http://`, `https://`, any `scheme://`) is never handed
--     back unchanged: `Convert:resolve()` in snacks' image/convert.lua
--     spawns curl (falling back to wget) on anything matching `^%w%w+://`,
--     with no further opt-out once it gets there. Returning a string with
--     no scheme and no matching file makes `Convert:run()` fail on its own
--     "File not found" check instead -- no process is ever spawned.
local function resolve(file, src)
  if src:match("^%a[%w+.-]*://") then
    return "phi-notes-remote-image-blocked"
  end
  if not src:find("/") then
    local attachments = vault.attachments_dir(file)
    if attachments then
      return vim.fs.joinpath(attachments, src)
    end
  end
  return nil
end

local M = {}

function M.setup()
  require("snacks").setup({
    image = {
      enabled = true,
      resolve = resolve,
      doc = {
        enabled = true, -- matches upstream default; explicit since this is the point
        inline = true, -- render in the buffer over kitty's graphics protocol
      },
      math = {
        enabled = true, -- `$...$`, `$$...$$` and ```math fences
        -- Rendered through pdflatex: commands.tex in snacks' convert.lua
        -- tries `tectonic` first and falls back to the next executable on
        -- PATH, and only pdflatex is installed on any phiOS host.
      },
      -- PDFs: convert.lua's default `magick.pdf` args already pass
      -- `{src}[{page}]` with page defaulting to 0, so the first page is
      -- previewed automatically through ImageMagick -- nothing to set here.
      --
      -- Mermaid (```mermaid fences) has no enable flag of its own -- only
      -- `math.enabled` gates a type in doc.lua, and mermaid's is "chart".
      -- It renders through `mmdc`, which this profile never declares or
      -- installs (rule 1: no undeclared software), so it stays inert on
      -- every phiOS host by omission rather than by a config switch.
      -- TODO: there is no snacks option to disable it outright; revisit if
      -- upstream ever adds a chart/mermaid toggle next to `math.enabled`.
    },
    zen = {
      center = true, -- matches upstream default; explicit since it's the point
      -- toggles, win and backdrop are left at snacks' defaults: no colour
      -- literal belongs in this module.
    },
  })

  -- `![[name]]` and `![](src)` are both already covered by snacks' own
  -- markdown_inline/images.scm (the wikilink form resolves through its
  -- `image_description (shortcut_link (link_text))` pattern -- confirmed by
  -- parsing `![[test.png]]` and reading back the `image.src` capture).
  -- Inline/block LaTeX math (`$...$`, `$$...$$`) is not: treesitter-markdown
  -- parses it as a `latex_block` node, and snacks only queries for that
  -- inside `queries/latex/images.scm`, not `markdown_inline`. This module
  -- owns no queries/ directory to add a file to, so the query is extended
  -- from Lua instead, the same way a user query override normally would be:
  -- `; extends` pulls in snacks' own file, and the added pattern mirrors
  -- queries/norg/images.scm's `inline_math` -- tagging the node
  -- `image.lang = "latex"` so doc.lua's own latex transform (which strips
  -- the `$` delimiters and wraps the content for pdflatex) runs on it too.
  vim.treesitter.query.set(
    "markdown_inline",
    "images",
    [[
; extends

(latex_block
  (#set! image.lang "latex")
  (#set! image.ext "math.tex")) @image.content @image
]]
  )

  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc })
  end

  map("n", "<leader>nr", function()
    require("phi.reading").toggle()
  end, "Toggle reading mode")
  map("n", "<leader>nt", function()
    require("phi.reading").typewriter()
  end, "Toggle typewriter scrolling")

  pcall(function()
    require("which-key").add({
      { "<leader>n", group = "notes" },
    })
  end)
end

return M

#!/usr/bin/env bash
#
# render-phi-png.sh — regenerate the Plymouth mark from phi-ascii.txt.
#
# NOT part of the install path and NOT in the R9 dependency budget: this is
# an off-machine design-asset tool, run by hand when phi-ascii.txt or the
# palette changes (design/brand/README.md's "manual re-sync"). It needs
# ImageMagick and a monospace font with box-drawing coverage (DejaVu Sans
# Mono).
#
# Plymouth cannot render aligned monospace text reliably (its Image.Text
# font argument is not dependable across builds), so the ASCII mark is
# baked to a raster here and shipped as phi.png — the same "output only,
# not the script" arrangement design/brand/README.md already describes,
# now with the script kept so the step is one command.
#
# Colour is PHI_FG_0 dark (#d6d1c9), literal for the same reason every
# boot asset is (Plymouth runs before phi; see README.md).

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
src=$here/phi-ascii.txt
out=$here/../../profiles/desktop/system/usr/share/plymouth/themes/phi/phi.png

fg='#d6d1c9'
font=${PHI_MARK_FONT:-/usr/share/fonts/TTF/DejaVuSansMono.ttf}
height=${PHI_MARK_HEIGHT:-480}

command -v magick >/dev/null || { echo "need ImageMagick (magick)" >&2; exit 1; }
[[ -f $font ]] || { echo "font not found: $font (set PHI_MARK_FONT)" >&2; exit 1; }

magick -background none -fill "$fg" -font "$font" \
       -pointsize 120 -interline-spacing -14 "label:@$src" \
       -trim +repage -resize "x$height" +repage "$out"

echo "wrote $out ($(identify -format '%wx%h' "$out"))"

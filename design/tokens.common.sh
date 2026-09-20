# phiOS — design tokens shared by every variant.
#
# THE SINGLE SOURCE. No colour, font name, size, radius, motion value or
# z-layer may appear in any other file in any of the four repositories.
#
# Format contract: plain KEY=VALUE, one per line, no command substitution
# and no conditionals. The file is sourced by bash and parsed by Go with a
# line splitter and no library. Keep it that way.
#
# Naming: PHI_ + the abstract token name in upper snake case.
# `bg-0` is PHI_BG_0, `motion-b-duration` is PHI_MOTION_B_DURATION. Abstract
# names only, never literal ones: there is no PHI_PINK and there never will be.
#
# Units are carried in the value (`2px`, `120ms`, `1ch`). A consumer that needs
# a bare number strips the trailing unit; the unit is part of the token so a
# template never has to know which one applies.
#
# ---------------------------------------------------------------------------
# PLACEHOLDERS — every value in this file that was invented rather than
# carried forward from something that already runs on the machines. Colour
# provenance is tracked separately, in tokens.dark.sh.
#
#   PHI_FONT_MONO/READING/UI/SYMBOL  family strings. Must all exist on the
#                              system's fontconfig; values are verified.
#   PHI_FONT_SIZE_*            base size and ratio; see the group note.
#   PHI_SPACE_*                spacing multiples. The 1ch unit is required.
#   PHI_RADIUS_BASE            2px base radius. [PLACEHOLDER] on fractional HiDPI.
#   PHI_BORDER_WIDTH           stroke hairline width.
#   PHI_RADIUS_SMALL/LARGE     fixed radii: 1px and 4px.
#   PHI_BORDER_WIDTH_STRONG    panel border width (currently equals hairline).
#   PHI_PANEL_PADDING          panel edge inset, flat (not a spacing multiple).
#   PHI_FONT_SCALE/SPACE_SCALE identity by default. The settings panel's Theme
#                              section may override these for per-user adjustment.
#   PHI_Z_*                    layering order; only the ordering matters.
#   PHI_MOTION_*               motion categories: tracking, state, emphasis, ambient.
#   PHI_CURSOR_*               cursor theme and size.
#   PHI_TERM_PADDING           kitty window padding. Bare number, no unit.
# ---------------------------------------------------------------------------

# --- Typography roles --------------------------------------------------
# Four roles, not four fonts: fontconfig chains them, so no single family has
# to carry every glyph. Patched fonts are not allowed; the symbol font is a
# separate glyphs-only family in the fallback chain, and in kitty it requires
# symbol_map directives.

PHI_FONT_MONO='Source Code Pro'
PHI_FONT_READING='Source Serif 4'
PHI_FONT_UI='Source Sans 3'

# Glyphs only, never a text font. Mono metrics (not proportional "Symbols Nerd
# Font"): a terminal grid needs every cell the same width. In the fallback
# chain it sits between font-mono and targeted Noto. Ships as ttf-nerd-fonts-
# symbols-mono.
PHI_FONT_SYMBOL='Symbols Nerd Font Mono'

# --- Cursor theme --------------------------------------------------
# One theme for every consumer: Hyprland, GTK, and Qt/the shell all resolve
# XCURSOR_THEME. Not variant-dependent, so it lives here rather than in the
# colour token files.
PHI_CURSOR_THEME='whiteglass'
PHI_CURSOR_SIZE='24'

# --- Size scale -------------------------------------------------------
# Derived from a 13px base at ~1.125 ratio (major second), rounded to whole
# pixels and hand-tightened at the top. Index 1 is the base; index 0 is one
# step below, so the scale does not start at the base. Index 1 is also the
# cell-width basis for every `1ch` spacing token in phi-shell.
PHI_FONT_SIZE_0='11px'
PHI_FONT_SIZE_1='13px'
PHI_FONT_SIZE_2='14px'
PHI_FONT_SIZE_3='16px'
PHI_FONT_SIZE_4='18px'
PHI_FONT_SIZE_5='21px'
PHI_FONT_SIZE_6='24px'

# --- Spacing -------------------------------------------------------
# Multiples of 1ch of PHI_FONT_MONO: the GUI rhythm is pinned to the
# terminal's character grid, not an independent pixel scale. `ch` is resolved
# to pixels by whoever draws; the shell measures the font, templates that need
# pixels do the arithmetic. Storing pixels here would break silently if the
# font family changes.
PHI_SPACE_1='1ch'
PHI_SPACE_2='2ch'
PHI_SPACE_3='3ch'
PHI_SPACE_4='4ch'
PHI_SPACE_5='6ch'
PHI_SPACE_6='8ch'

# --- Shape -------------------------------------------------------
# radius-base is the base radius. [PLACEHOLDER] on fractional HiDPI.
PHI_RADIUS_BASE='2px'
PHI_RADIUS_PILL='9999px'

# radius-small / radius-large: fixed radii for UI elements that don't scale
# with radius-base. Status bar islands round at 1px (nearly sharp); panels
# round at 4px (softer than most other controls).
PHI_RADIUS_SMALL='1px'
PHI_RADIUS_LARGE='4px'

# border-width: stroke width for separators, panel borders, and focus rings.
# A hairline is a universal UI constant, not a design decision.
PHI_BORDER_WIDTH='2px'

# border-width-strong: panel border width. Kept as its own token because it is
# a distinct role (a surface's outline vs. a control's outline) and may diverge
# from border-width later.
PHI_BORDER_WIDTH_STRONG='1px'

# panel-padding: panel edge inset, flat (not a spacing multiple). Independent
# of the font's cell width, unlike the space-N scale which governs gaps between
# elements. Both panel-padding and the per-user Theme scale are editable.
PHI_PANEL_PADDING='8px'

# term-padding: kitty window padding. A distinct role (kitty's own window
# chrome, not a phi-shell Panel inset) that may diverge from panel-padding.
# Bare number, no unit. Overridable per-user via `phi state`'s terminal.padding.
PHI_TERM_PADDING='40'

# panel-gap / panel-radius: the inset below-the-bar surfaces (notifications,
# docks, popouts, calendar) maintain from the bar and screen edges, and their
# corner radius. Both per-user editable (settings > Theme > Shape & spacing).
PHI_PANEL_GAP='2px'
PHI_PANEL_RADIUS='6px'

# slider-thickness: the visible track height of volume/brightness OSD and
# in-shell sliders — a thin rail.
PHI_SLIDER_THICKNESS='4px'

# --- User-tunable scale ------------------------------------------------
# Identity by default. The settings panel's Theme section writes a per-user
# override into $XDG_STATE_HOME/phi/theme-overrides.json (never this file).
# font-scale multiplies the whole size scale; space-scale multiplies the
# whole spacing scale. Dimensionless factors.
PHI_FONT_SCALE='1'
PHI_SPACE_SCALE='1'

# --- Layering -------------------------------------------------------
# Only the order is specified. Gaps of 100 allow inserting surfaces between
# layers without renumbering the rest.
PHI_Z_BASE='0'
PHI_Z_BAR='100'
PHI_Z_POPOVER='200'
PHI_Z_MODAL='300'
PHI_Z_TOOLTIP='400'
PHI_Z_NOTIFICATION='500'

# --- Motion -------------------------------------------------------
# Four categories: weight is inverse to frequency of use.
#
# A — tracking feedback (kitty cursor trail, agent indicator). Continuous and
# light, linear (eased loop reads as a pulse).
PHI_MOTION_A_PERIOD='1600ms'
PHI_MOTION_A_EASING='linear'

# B — state transition (windows, panels, drawers, workspaces, notifications).
# High frequency, short and ease-out. Springy motion belongs to a different
# category. '0.25,0.46,0.45,0.94' is the cubic-bezier equivalent of
# Qt's Easing.OutQuad.
PHI_MOTION_B_DURATION='120ms'
PHI_MOTION_B_EASING='ease-out'
PHI_MOTION_B_BEZIER='0.25,0.46,0.45,0.94'

# C — emphasis, rare events (boot, unlock, first run). Only two allowed:
# per-character typing and random-letter scramble that resolves.
PHI_MOTION_C_TYPE_STEP='24ms'
PHI_MOTION_C_SCRAMBLE='600ms'
PHI_MOTION_C_EASING='linear'

# D — ambient indicators. Animation forbidden by default.
PHI_MOTION_D_DURATION='0ms'

# --- Wallpaper texture catalogue ----------------------------------------
# The procedural textures the shell's background layer can composite. This
# list is a design decision; `phi wallpaper texture` is the generator and
# validates against this. Space-separated, menu order.
PHI_TEXTURE_MODES='grain noise paper leather rock fabric'
PHI_TEXTURE_INTENSITY_DEFAULT='40'

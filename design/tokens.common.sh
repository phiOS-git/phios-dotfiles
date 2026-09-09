# phiOS — design tokens shared by every variant (master plan §6.3, §6.5).
#
# THE SINGLE SOURCE. No colour, font name, size, radius, motion value or
# z-layer may appear in any other file in any of the four repositories (I-05).
#
# Format contract (§6.1): plain KEY=VALUE, one per line, no command
# substitution and no conditionals. The file is sourced by bash and parsed by
# Go with a line splitter and no library. Keep it that way.
#
# Naming: PHI_ + the abstract token name of §6.2/§6.3 in upper snake case.
# `bg-0` is PHI_BG_0, `motion-b-duration` is PHI_MOTION_B_DURATION. Abstract
# names only, never literal ones (ADR 060, architettura §7.2): there is no
# PHI_PINK and there never will be.
#
# Units are carried in the value, as §6.3 writes them (`2px`, `120ms`, `1ch`).
# A consumer that needs a bare number strips the trailing unit; the unit is
# part of the token so a template never has to know which one applies.
#
# ---------------------------------------------------------------------------
# PLACEHOLDERS — every value in this file that was invented rather than
# carried forward from something that already runs on the machines. Colour
# provenance is tracked separately, in tokens.dark.sh.
#
#   PHI_FONT_MONO/READING/UI/SYMBOL  family strings, §6.4/S-51. The packages
#                              are M5 (§15.2) and, as of this commit, declared
#                              in profiles/base/packages.txt but not yet
#                              installed on any real machine — every string
#                              below is unverified against a real fc-list
#                              until the user installs them (§6.4's own "Q-N01
#                              closes at S-51" is done: Source Code Pro).
#   PHI_FONT_SIZE_*            base and ratio invented; see the group note.
#   PHI_SPACE_*                the multipliers are invented; the 1ch unit is
#                              required by §6.3.
#   PHI_RADIUS_BASE            2px, from §6.3, where it is itself marked
#                              [PLACEHOLDER] pending a look at fractional HiDPI.
#   PHI_BORDER_WIDTH           1px, added at S-21 (not in §6.3 at all — a real
#                              gap, not a deferred decision). Same fractional-
#                              HiDPI caveat as PHI_RADIUS_BASE.
#   PHI_Z_*                    invented; only the ordering is specified.
#   PHI_MOTION_*               all durations invented. §6.5 fixes the four
#                              categories and their character, not any
#                              number. S-52 audited every real consumer
#                              against these values and found no reason to
#                              change them — still invented numbers, no
#                              longer untested ones.
#   PHI_CURSOR_*               S-54. Theme name is closed (whiteglass); size
#                              (24) is a plain, common default, not measured
#                              against any real HiDPI screen.
# ---------------------------------------------------------------------------

# --- Typography roles (§6.3, §6.4) -----------------------------------------
# Four roles, not four fonts: fontconfig chains them, so no single family has
# to carry every glyph (architettura §7.3). ADR 054 forbids patched fonts —
# the symbol font is a separate glyphs-only family in the fallback chain, and
# in kitty it additionally needs symbol_map directives (§6.4).

# Q-N01 closed at S-51, by the user's own choice over the master plan's
# Iosevka proposal: Source Code Pro is the third member of the same Adobe
# superfamily as font-reading/font-ui below, for typographic coherence across
# all three text roles — the style plan's own original stated value, ahead of
# Iosevka's narrower cell.
PHI_FONT_MONO='Source Code Pro'

# Closed in §6.4.
PHI_FONT_READING='Source Serif 4'
PHI_FONT_UI='Source Sans 3'

# Glyphs only, never a text font: it exists to be second in the fallback
# chain (§6.4's "1. font-mono, 2. font-symbol, 3. targeted Noto"). Mono
# metrics (S-51), not the proportional "Symbols Nerd Font": a terminal grid
# needs every cell the same width, and an icon glyph at the wrong advance
# width would misalign the column after it. Ships as the ttf-nerd-fonts-
# symbols-mono split of the §15.2 package.
PHI_FONT_SYMBOL='Symbols Nerd Font Mono'

# --- Cursor theme (§6.7 class 5, S-54) --------------------------------------
# "Thin, black, white-outlined" (architettura §8.2.3): xcursor-themes'
# bundled "whiteglass" conforms, by the user's own choice over producing a
# bespoke one — approved this session, not in master plan §15 before now.
# One value for every consumer: Hyprland's own cursor, GTK, and Qt/the
# shell all resolve XCURSOR_THEME (hyprland.lua.tmpl's own S-54 note has
# the per-toolkit detail). Not variant-dependent, so it lives here rather
# than in tokens.dark.sh/tokens.light.sh.
PHI_CURSOR_THEME='whiteglass'
PHI_CURSOR_SIZE='24'

# --- Size scale (§6.3) ------------------------------------------------------
# Derived, not arbitrary: a 14px base at a 1.125 ratio (major second), rounded
# to whole pixels. Index 1 is the base; index 0 is the one step below it, which
# is why the scale does not start at the base. Two decisions are placeholders,
# the base and the ratio, and both are one line each.
PHI_FONT_SIZE_0='12px'
PHI_FONT_SIZE_1='14px'
PHI_FONT_SIZE_2='16px'
PHI_FONT_SIZE_3='18px'
PHI_FONT_SIZE_4='20px'
PHI_FONT_SIZE_5='22px'
PHI_FONT_SIZE_6='25px'

# --- Spacing (§6.3) ---------------------------------------------------------
# Multiples of 1ch of PHI_FONT_MONO, which is the point: the GUI rhythm is
# pinned to the terminal's character grid rather than to an independent px
# scale. `ch` is resolved to pixels by whoever draws — the shell measures the
# font, a template that needs px does the arithmetic. Storing px here would
# silently break the moment Q-N01 changes the mono family.
PHI_SPACE_1='1ch'
PHI_SPACE_2='2ch'
PHI_SPACE_3='3ch'
PHI_SPACE_4='4ch'
PHI_SPACE_5='6ch'
PHI_SPACE_6='8ch'

# --- Shape (§6.3) -----------------------------------------------------------
# radius-base is 2px in §6.3 and marked [PLACEHOLDER] there: it has to be
# looked at on fractional HiDPI before it is real.
PHI_RADIUS_BASE='2px'
PHI_RADIUS_PILL='9999px'

# border-width has no home in §6.3's own token table — added at S-21, where
# the widget library found the gap: a separator, a panel border and a focus
# ring all need a stroke width, and DONE WHEN forbids a literal size in any
# widget. A hairline is a universal UI constant, not a design decision, so
# one token rather than a per-widget guess. [PLACEHOLDER] the same way
# radius-base is: unverified on real HiDPI/fractional-scaling output.
PHI_BORDER_WIDTH='1px'

# --- Layering (§6.3) --------------------------------------------------------
# Only the order is specified. The gaps of 100 exist so a surface can be
# slipped between two layers without renumbering the rest.
PHI_Z_BASE='0'
PHI_Z_BAR='100'
PHI_Z_POPOVER='200'
PHI_Z_MODAL='300'
PHI_Z_TOOLTIP='400'
PHI_Z_NOTIFICATION='500'

# --- Motion (§6.5) ----------------------------------------------------------
# Weight is inverse to frequency of use. The four categories are binding; the
# numbers are not, and S-52 replaces them.

# A — tracking feedback: kitty cursor_trail, the agent's processing indicator.
# Continuous and light. Linear, because an eased loop reads as a pulse.
PHI_MOTION_A_PERIOD='1600ms'
PHI_MOTION_A_EASING='linear'

# B — state transition: windows, panels, drawers, workspaces, notifications
# and toasts. High frequency, so "quasi istantaneo, nessun easing organico":
# short and ease-out. Anything springy belongs to a category that is not B.
PHI_MOTION_B_DURATION='120ms'
PHI_MOTION_B_EASING='ease-out'

# C — emphasis, rare events: boot, unlock, first run. Exactly two effects are
# admitted, per-character typing and a random-letters scramble that resolves.
# A loader in category C is only allowed if its resolution coincides with the
# real completion of the process. Letter-roll on titles was removed and is not
# to come back.
PHI_MOTION_C_TYPE_STEP='24ms'
PHI_MOTION_C_SCRAMBLE='600ms'
PHI_MOTION_C_EASING='linear'

# D — ambient indicators. Animation is forbidden by default; an exception has
# to be justified where it is taken.
PHI_MOTION_D_DURATION='0ms'

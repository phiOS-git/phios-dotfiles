# phiOS — colour tokens, dark variant (master plan §6.2).
#
# Read design/tokens.common.sh first for the format contract and the naming
# rule. Both variants are permanent and neither derives from the other (R6);
# every token defined here is defined in tokens.light.sh too.
#
# Colours are #rrggbb. The one exception is PHI_OVERLAY_SCRIM, which is
# #rrggbbaa because a scrim without alpha is not a scrim.
#
# ---------------------------------------------------------------------------
# PROVENANCE. This is the *starting* dark palette, not the final one. S-51
# derives the real palette in OKLCH; until then every value below is one of:
#
#   [carried]     the value that renders on zotac and razer today. Nine came
#                 from theme.sh, the rest from the fixed pairings inside the
#                 current templates (kitty's cursor_text_color, btop's
#                 selected_fg, yazi's count_* foregrounds). S-03 rewrote the
#                 templates onto the token names and checked that all six
#                 render byte-identically; changing one of these now changes
#                 what the machines display.
#   [filled]      a slot §6.2 requires that today's palette has no value for.
#                 Interpolated in OKLab lightness along the ramp its neighbours
#                 already define. This is gap-filling, not derivation.
#
#   theme.sh name        token         hex
#   PHI_BG               bg-0          #1a1918
#   PHI_SURFACE          bg-1          #242320
#   PHI_FG               fg-0          #d6d1c9
#   PHI_FG_DIM           fg-2          #7d786f
#   PHI_ACCENT           accent        #d3a0ac
#   PHI_ERROR            error         #b57b73
#   PHI_WARN             warn          #c0a874
#   PHI_SUCCESS          success       #8fa77e
#   PHI_INFO             info          #7f95ab
#
# FG_DIM sits at fg-2 and not at fg-1 because §6.2 requires a uniform
# progression in perceptual luminance. #d6d1c9 is L=0.862 and #7d786f is
# L=0.574 in OKLab; putting the second at fg-1 would force fg-2 and fg-3 below
# the background. At fg-2 the four steps are even, 0.144 apart.
#
# CONTRAST, measured, not asserted. Ratios are WCAG 2.x against bg-0:
#   fg-0 11.56:1   fg-1 7.00:1   fg-2 4.00:1   fg-3 2.16:1
#   accent 7.85:1  error 5.05:1  warn 7.60:1  success 6.69:1  info 5.68:1
# Two of these are below the 4.5:1 minimum §6.2 sets for normal text:
#   fg-2 at 4.00:1 — and it is today's comment and secondary-text colour, so
#     this is a real failure on the running machines, not a hypothetical one.
#   fg-3 at 2.16:1 — non-text by construction (dividers, disabled marks). It
#     is recorded rather than fixed because raising it would collapse the ramp.
# Both are S-51's to resolve, and §6.2 requires the check to be executable by
# then (`phi theme check`). It is not executable yet; these numbers were
# computed off-machine and are as good as the arithmetic behind them.
# ---------------------------------------------------------------------------

# --- Variant identity ------------------------------------------------------
# Which of the two permanent variants this file is. Not a colour, but it
# belongs here rather than in tokens.common.sh precisely because it is the
# one thing the two palettes disagree about by definition. A target that has
# to declare a light/dark preference rather than a colour reads this.
PHI_VARIANT='dark'

# --- Tier 0: structure (§6.2) ----------------------------------------------
# bg-N rises toward the viewer: bg-0 is the deepest surface, bg-3 the most
# elevated. fg-N recedes: fg-0 is primary text, fg-3 the faintest mark.
PHI_BG_0='#1a1918'            # [carried] PHI_BG
PHI_BG_1='#242320'            # [carried] PHI_SURFACE
PHI_BG_2='#2e2d2a'            # [filled]  +1 ramp step
PHI_BG_3='#393835'            # [filled]  +2 ramp steps

PHI_FG_0='#d6d1c9'            # [carried] PHI_FG — primary text
PHI_FG_1='#a8a39b'            # [filled]  midpoint of fg-0 and fg-2
PHI_FG_2='#7d786f'            # [carried] PHI_FG_DIM — secondary text, comments
PHI_FG_3='#544f47'            # [filled]  -1 ramp step — non-text

PHI_BORDER='#242320'          # [carried] kitty inactive_border_color
PHI_BORDER_STRONG='#3e3d3a'   # [filled]  same hue at L=0.360
PHI_OVERLAY_SCRIM='#00000099' # [filled]  black at 60%

# --- Tier 1: accent (§6.2) --------------------------------------------------
# One role and one only: active state, focus, primary interactivity. The
# settings panel will make it configurable, which is the reason it is a single
# token and not a family.
PHI_ACCENT='#d3a0ac'          # [carried] PHI_ACCENT
PHI_ACCENT_FG='#1a1918'       # [carried] kitty cursor_text_color, btop selected_fg

# --- Tier 2: semantic (§6.2) ------------------------------------------------
# On threshold or state only, never as decoration. The direction is oxide,
# ochre, moss, slate, all desaturated; the values are a hue direction, not a
# decision, and §6.2 says so explicitly.
PHI_ERROR='#b57b73'           # [carried] PHI_ERROR
PHI_ERROR_FG='#1a1918'        # [carried] yazi count_cut foreground
PHI_WARN='#c0a874'            # [carried] PHI_WARN
PHI_WARN_FG='#1a1918'         # [carried] same pairing
PHI_SUCCESS='#8fa77e'         # [carried] PHI_SUCCESS
PHI_SUCCESS_FG='#1a1918'      # [carried] yazi count_copied foreground
PHI_INFO='#7f95ab'            # [carried] PHI_INFO
PHI_INFO_FG='#1a1918'         # [carried] same pairing

# --- Tier 3: syntax (§6.2) --------------------------------------------------
# For disambiguating categories that appear at the same time: code, logs,
# diffs. [filled] as a set — each one is mapped onto a hue that already
# exists rather than inventing six new ones. S-51 gives them their own chroma
# so a keyword and a string stop borrowing the accent and the success colour.
PHI_SYNTAX_1='#d3a0ac'        # keyword          -> accent
PHI_SYNTAX_2='#8fa77e'        # string           -> success
PHI_SYNTAX_3='#c0a874'        # number, constant -> warn
PHI_SYNTAX_4='#7f95ab'        # function         -> info
PHI_SYNTAX_5='#b57b73'        # type             -> error
PHI_SYNTAX_6='#7d786f'        # operator, punct. -> fg-2

# --- Selection and terminal cursor (§6.2) -----------------------------------
PHI_SELECTION_BG='#242320'    # [carried] kitty selection_background
PHI_SELECTION_FG='#d6d1c9'    # [carried] kitty selection_foreground
PHI_CURSOR_TERM='#d3a0ac'     # [carried] kitty cursor — separate from the GUI cursor

# --- ANSI 16 (§6.2, ADR 053) ------------------------------------------------
# This is the base16-style surface ADR 053 asks for: the sixteen slots every
# terminal tool assumes for errors, warnings, diffs and file types. It is not
# a second palette — every value here is one of the tokens above.
#
# [carried] exactly as today's kitty theme renders, which is what keeps S-03
# output-identical. §6.2 wants this map derived rather than hand-picked, and
# two things are wrong with it until S-51 does that:
#   - bright is identical to normal for all six chromatic pairs, so a tool
#     that uses bright to add emphasis adds nothing.
#   - slot 6/14 (cyan) is the same value as 4/12 (blue). A tool that uses both
#     cannot be told apart.
PHI_ANSI_0='#242320'          # black          -> bg-1
PHI_ANSI_1='#b57b73'          # red            -> error
PHI_ANSI_2='#8fa77e'          # green          -> success
PHI_ANSI_3='#c0a874'          # yellow         -> warn
PHI_ANSI_4='#7f95ab'          # blue           -> info
PHI_ANSI_5='#d3a0ac'          # magenta        -> accent
PHI_ANSI_6='#7f95ab'          # cyan           -> info (collision, S-51)
PHI_ANSI_7='#d6d1c9'          # white          -> fg-0
PHI_ANSI_8='#7d786f'          # bright black   -> fg-2
PHI_ANSI_9='#b57b73'          # bright red
PHI_ANSI_10='#8fa77e'         # bright green
PHI_ANSI_11='#c0a874'         # bright yellow
PHI_ANSI_12='#7f95ab'         # bright blue
PHI_ANSI_13='#d3a0ac'         # bright magenta
PHI_ANSI_14='#7f95ab'         # bright cyan
PHI_ANSI_15='#d6d1c9'         # bright white   -> fg-0

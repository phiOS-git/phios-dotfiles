# phiOS — colour tokens, light variant.
#
# Read design/tokens.common.sh first for the format contract and the naming
# rule, and tokens.dark.sh for the provenance of the values this variant is
# built from. Both variants are permanent and independent: this file is a
# complete palette, not a transform applied to the dark one.
#
# ---------------------------------------------------------------------------
# PROVENANCE — colours are derived algorithmically in OKLCH and checked
# against `phi theme check` (see phi/internal/theme/check.go for WCAG validation).
# Nothing here is carried from live systems; every value is derived:
#
#   Structure (bg-*, fg-0). An affine map on OKLab lightness:
#   L_light = -1.18776 * L_dark + 1.22436, applied to each dark token with
#   its a and b untouched. Fixed points: dark bg-0 -> light bg-0 at L=0.970,
#   dark fg-0 -> light fg-0 at L=0.200. Hue and chroma survive.
#
#   fg-1/fg-2/fg-3. Solved individually (not by affine map) for a uniform
#   4-point ramp. fg-0 is the affine-mapped anchor; fg-2 is solved at
#   (H=82.39°, C=0.0150) for 4.6:1 against light bg-0; fg-1 and fg-3 are
#   the remaining two points.
#
#   Accent and Tier 2 semantics. Not affine-mapped (would place them too
#   dark). Each keeps dark hue/chroma and gets lightness solved for a target
#   against light bg-0: 4.8:1 for accent, 4.9:1 for Tier 2 roles.
#
#   Tier 3 syntax. Same method as tokens.dark.sh: each role's dark hue/chroma,
#   lightness solved for a shared syntax-legibility target (4.7:1, distinct
#   from Tier 2's 4.9:1 to prevent collisions).
#
#   ANSI 16. Same approach as tokens.dark.sh: new H=195° cyan anchor and
#   bright variants at higher chroma/contrast.
#
# CONTRAST, measured against this variant's bg-0 (#f6f5f3):
#   fg-0 16.67:1   fg-1 9.58:1   fg-2 4.59:1   fg-3 2.33:1
#   accent 4.82:1  error 4.92:1  warn 4.92:1  success 4.88:1  info 4.90:1
# Every text pair (fg-0/1/2, accent, error, warn, success, info) clears 4.5:1.
# ---------------------------------------------------------------------------

# --- Variant identity -----------------------------------------------
# Which of the two permanent variants this file is. Not a colour, but it
# belongs here rather than in tokens.common.sh precisely because it is the
# one thing the two palettes disagree about by definition. A target that has
# to declare a light/dark preference rather than a colour reads this.
PHI_VARIANT='light'

# --- Tier 0: structure -----------------------------------------------
# The indices mean what they do in the dark variant: bg-N rises toward the
# viewer (gets darker in light variant), fg-N recedes from primary text. A
# template written against bg-0/fg-0 is correct in both without knowing which
# variant it is.
PHI_BG_0='#f6f5f3'
PHI_BG_1='#e6e4e0'
PHI_BG_2='#d6d5d1'
PHI_BG_3='#c5c4c0'

PHI_FG_0='#191510'            # primary text
PHI_FG_1='#443f37'            # [derived] same H/C as fg-2, ramp point 1 of 4
PHI_FG_2='#736f66'            # secondary text, comments — [derived] H=82.39° C=0.0150, solved for 4.6:1
PHI_FG_3='#a7a298'            # non-text — [derived] same H/C as fg-2, ramp point 3 of 4

PHI_BORDER='#e6e4e0'
PHI_BORDER_STRONG='#bebdb9'
PHI_OVERLAY_SCRIM='#19151073' # fg-0 at 45% — a light scrim is ink, not black
# See PHI_OVERLAY_SCRIM_STRONG's comment in tokens.dark.sh — same hue, a
# harder alpha step, for the small set of full-attention blocking surfaces.
PHI_OVERLAY_SCRIM_STRONG='#191510a6' # fg-0 at 65%

# --- Tier 1: accent (§6.2) --------------------------------------------------
PHI_ACCENT='#8e5f6b'          # second lightness of #d3a0ac — 4.82:1 on bg-0
PHI_ACCENT_FG='#f6f5f3'

# --- Tier 2: semantic (§6.2) ------------------------------------------------
# S-50: same hue/chroma as the dark variant's carried anchors, lightness
# re-solved for a uniform 4.9:1 target (nudged up from S-02's ~4.78-4.83).
PHI_ERROR='#945c55'
PHI_ERROR_FG='#f6f5f3'
PHI_WARN='#7e6835'
PHI_WARN_FG='#f6f5f3'
PHI_SUCCESS='#5b724b'
PHI_SUCCESS_FG='#f6f5f3'
PHI_INFO='#596d82'
PHI_INFO_FG='#f6f5f3'

# --- Tier 3: syntax (§6.2) --------------------------------------------------
# S-50: each role's own hue (same as the dark variant), lightness solved for
# a shared 4.7:1 syntax-legibility target instead of borrowing its Tier 1/2
# counterpart's own value — see the file header for why 4.7, not 4.9.
PHI_SYNTAX_1='#90616d'        # keyword          -> accent hue,  H=2.72°   C=0.0624
PHI_SYNTAX_2='#5f7450'        # string           -> success hue, H=132.18° C=0.0599
PHI_SYNTAX_3='#816b38'        # number, constant -> warn hue,    H=85.85°  C=0.0745
PHI_SYNTAX_4='#5b7085'        # function         -> info hue,    H=248.45° C=0.0413
PHI_SYNTAX_5='#956059'        # type             -> error hue,   H=27.99°  C=0.0701
PHI_SYNTAX_6='#736f66'        # operator, punct. -> fg-2 (same token, no separate hue: muted ink, not a category)

# --- Selection and terminal cursor (§6.2) -----------------------------------
PHI_SELECTION_BG='#e6e4e0'
PHI_SELECTION_FG='#191510'
PHI_CURSOR_TERM='#8e5f6b'

# --- ANSI 16 ---------------------------------------------------------------
# Chromatic slots follow the dark variant's mapping (same hue anchors), so a
# tool themed for one variant is themed for the other. Achromatic slots don't
# mirror indices: slot 0 is "black" and slot 7 is "white" to tools, taking
# this variant's darkest and lightest structural tones. Mirroring indices
# would make color0 pale and every tool printing on it would disappear.
# Bright variants are the same hues at higher chroma/contrast.
PHI_ANSI_0='#191510'          # black          -> fg-0
PHI_ANSI_1='#945c55'          # red            -> error
PHI_ANSI_2='#5b724b'          # green          -> success
PHI_ANSI_3='#7e6835'          # yellow         -> warn
PHI_ANSI_4='#596d82'          # blue           -> info
PHI_ANSI_5='#8e5f6b'          # magenta        -> accent
PHI_ANSI_6='#1f7878'          # cyan           -> new anchor, H=195° C=0.08, solved 4.8:1
PHI_ANSI_7='#c5c4c0'          # white          -> bg-3
PHI_ANSI_8='#736f66'          # bright black   -> fg-2 (S-50's fixed value)
PHI_ANSI_9='#915048'          # bright red     -> error hue, higher C, solved 5.6:1
PHI_ANSI_10='#4e6a37'         # bright green   -> success hue, higher C, solved 5.6:1
PHI_ANSI_11='#785c09'         # bright yellow  -> warn hue, higher C, solved 5.8:1
PHI_ANSI_12='#4c6783'         # bright blue    -> info hue, higher C, solved 5.4:1
PHI_ANSI_13='#8a4c5d'         # bright magenta -> accent hue, higher C, solved 5.9:1
PHI_ANSI_14='#0c7071'         # bright cyan    -> slot-6 hue, higher C, solved 5.4:1
PHI_ANSI_15='#e6e4e0'         # bright white   -> bg-1

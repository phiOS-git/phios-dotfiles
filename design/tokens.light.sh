# phiOS — colour tokens, light variant (master plan §6.2).
#
# Read design/tokens.common.sh first for the format contract and the naming
# rule, and tokens.dark.sh for the provenance of the values this variant is
# built from. Both variants are permanent and neither derives from the other
# at runtime (R6): this file is a complete palette, not a transform applied to
# the dark one.
#
# ---------------------------------------------------------------------------
# PROVENANCE — S-50, the real derivation §6.2 requires, checked against
# `phi theme check` (zero violations — see phi/internal/theme/check.go).
# Nothing in this file has ever rendered on a machine; there is no light
# variant running today, so nothing here is [carried] the way some of
# tokens.dark.sh is. Every value is [derived]:
#
#   Structure (bg-*, fg-0). One affine map on OKLab lightness, unchanged
#   since S-02: L_light = -1.18776 * L_dark + 1.22436, applied to each dark
#   token with its a and b untouched. Fixed points: dark bg-0 -> light bg-0
#   at L=0.970, dark fg-0 -> light fg-0 at L=0.200. Hue and chroma survive, so
#   the light variant is the same warm neutral, not a different palette that
#   happens to be pale.
#
#   fg-1/fg-2/fg-3 — S-50 re-solves these instead of continuing the affine
#   map, for the same reason tokens.dark.sh does: a uniform 4-point ramp
#   needs its individual steps checked, not just its endpoints. fg-0 is the
#   affine-mapped anchor above; fg-2 is solved at fg-2's own (H=82.39°,
#   C=0.0150) for 4.6:1 against light bg-0 (the same target used in the dark
#   variant, for one documented algorithm instead of two); fg-1 and fg-3 are
#   the remaining two points of the uniform ramp through fg-0 and that solved
#   fg-2. (The prior affine-mapped fg-2, at 4.58:1, already cleared 4.5:1 —
#   this re-solve is for a shared, provable margin, not a fix to a failure.)
#
#   Accent and Tier 2 semantics. NOT the affine map — it drives them to
#   L~0.33, far darker than they need to be, and #4e2631 does not read as the
#   same rose. Instead each keeps its dark hue and chroma and gets a
#   lightness solved for a real target against light bg-0: 4.8:1 for accent
#   (unchanged since S-02), 4.9:1 for the four Tier 2 roles (nudged up from
#   S-02's ~4.78-4.83 for a uniform, documented margin instead of four
#   different near-floor values). That is the "second lightness" §6.2
#   requires:
#
#     "l'accento attuale #d3a0ac è ~9,4:1 su nero e ~2,2:1 su bianco. La
#      variante chiara richiede una seconda lightness dell'accento. Non è
#      opzionale: senza, la variante chiara è inaccessibile."
#
#   The measurement behind that: #d3a0ac is 2.24:1 on #ffffff. Reusing it in
#   this variant would put the accent at half the 4.5:1 floor. It is not
#   reused.
#
#   Tier 3 syntax. Same method as tokens.dark.sh: each role's dark hue/chroma,
#   lightness solved for a shared syntax-legibility target rather than
#   inheriting its Tier 1/2 counterpart's own contrast. The light-variant
#   target is 4.7:1, deliberately NOT the 4.9:1 used for Tier 2 above — at
#   the same hue/chroma, solving both tiers for the same ratio converges on
#   the identical lightness, so warn/error/info/type/number/function would
#   have collided pixel-for-pixel with their Tier 2 counterpart (found while
#   deriving this file, fixed before committing rather than shipped). 4.7:1
#   still clears the 4.5:1 floor with a real margin and lands each syntax
#   role at a visibly different lightness than its Tier 1/2 counterpart.
#
#   ANSI 16. Same fixes as tokens.dark.sh: a new H=195° cyan anchor distinct
#   from info/blue (H=248°) and success/moss (H=132°), and bright variants at
#   higher chroma and a higher contrast target than their normal counterpart.
#
# CONTRAST, measured against this variant's bg-0 (#f6f5f3) with `phi theme
# check`'s own WCAG formula:
#   fg-0 16.67:1   fg-1 9.58:1   fg-2 4.59:1   fg-3 2.33:1
#   accent 4.82:1  error 4.92:1  warn 4.92:1  success 4.88:1  info 4.90:1
# Every checked pair (fg-0/1/2, accent, error, warn, success, info) clears
# 4.5:1. fg-3 is non-text by construction and excluded, same as the dark
# variant. `phi theme check` on this file reports zero violations.
# ---------------------------------------------------------------------------

# --- Variant identity ------------------------------------------------------
# Which of the two permanent variants this file is. Not a colour, but it
# belongs here rather than in tokens.common.sh precisely because it is the
# one thing the two palettes disagree about by definition. A target that has
# to declare a light/dark preference rather than a colour reads this.
PHI_VARIANT='light'

# --- Tier 0: structure (§6.2) ----------------------------------------------
# The indices mean what they mean in the dark variant, which is the point of
# abstract names: bg-N still rises toward the viewer, so in this variant it
# gets darker rather than lighter, and fg-N still recedes from primary text.
# A template written against bg-0/fg-0 is correct in both without knowing which
# it is rendering.
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

# --- ANSI 16 (§6.2, ADR 053) ------------------------------------------------
# The chromatic slots follow the dark variant's mapping (same hue anchors),
# so a tool themed for one variant is themed for the other. The four
# achromatic slots do not mirror it: slot 0 is "black" and slot 7 is "white"
# to the tools that use them, so they take this variant's darkest and
# lightest structural tones rather than the same token index the dark
# variant used. Mirroring the index would make `color0` render pale, and
# every tool that prints on it would disappear.
#
# S-50 fixes the two defects the dark variant's own comment describes: a new
# H=195° cyan anchor (own value here, own value there, not shared with
# info/blue or success/moss) and bright variants solved at higher chroma and
# a higher contrast target than their normal counterpart, so bright is
# visibly different again, not a relabelling.
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

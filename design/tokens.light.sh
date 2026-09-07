# phiOS — colour tokens, light variant (master plan §6.2).
#
# Read design/tokens.common.sh first for the format contract and the naming
# rule, and tokens.dark.sh for the provenance of the values this variant is
# built from. Both variants are permanent and neither derives from the other
# at runtime (R6): this file is a complete palette, not a transform applied to
# the dark one. It was *constructed* from the dark one, once, here, and S-51
# replaces both together.
#
# ---------------------------------------------------------------------------
# PROVISIONAL — ALL OF IT. Nothing in this file has ever rendered on a
# machine. There is no light variant today, so nothing could be carried
# forward; every value below was constructed at S-02 and every one of them is
# S-51's to replace.
#
# How it was constructed, so S-51 can tell intent from accident:
#
#   Structure (bg-*, fg-*, border*). One affine map on OKLab lightness,
#   L_light = -1.18776 * L_dark + 1.22436, applied to each dark token with its
#   a and b untouched. The two fixed points are dark bg-0 -> light bg-0 at
#   L=0.970 and dark fg-0 -> light fg-0 at L=0.200. Hue and chroma survive, so
#   the light variant is the same warm neutral, not a different palette that
#   happens to be pale. The ramp stays uniform because an affine map preserves
#   equal spacing.
#
#   Accent and semantics. NOT the affine map — it drove them to L~0.33, far
#   darker than they need to be, and #4e2631 does not read as the same rose.
#   Instead each keeps its dark hue and chroma and gets a lightness solved for
#   ~4.8:1 against light bg-0. That is the "second lightness" §6.2 requires:
#
#     "l'accento attuale #d3a0ac è ~9,4:1 su nero e ~2,2:1 su bianco. La
#      variante chiara richiede una seconda lightness dell'accento. Non è
#      opzionale: senza, la variante chiara è inaccessibile."
#
#   The measurement behind that, recomputed here rather than taken on trust:
#   #d3a0ac is 2.24:1 on #ffffff. Reusing it in this variant would put the
#   accent at half the 4.5:1 floor. It is not reused.
#
# CONTRAST, measured, against this variant's bg-0 (#f6f5f3):
#   fg-0 16.67:1   fg-1 9.46:1   fg-2 4.58:1   fg-3 2.33:1
#   accent 4.82:1  error 4.80:1  warn 4.78:1  success 4.79:1  info 4.83:1
# Every text token clears 4.5:1, including fg-2, which fails in the dark
# variant. fg-3 at 2.33:1 is non-text by construction, same as its dark
# counterpart. The chromatic tokens clear the floor with almost no margin by
# design: solving for the threshold keeps them as light as accessibility
# allows, so they still read as colour rather than as dark ink. S-51 should
# treat ~4.8:1 as the floor it works up from, not as a target it hit.
#
# The executable check §6.2 requires (`phi theme check`) does not exist yet.
# These numbers were computed off-machine at S-02 and nothing on a machine has
# confirmed them.
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
PHI_FG_1='#444039'
PHI_FG_2='#746f66'            # secondary text, comments
PHI_FG_3='#a7a299'            # non-text

PHI_BORDER='#e6e4e0'
PHI_BORDER_STRONG='#bebdb9'
PHI_OVERLAY_SCRIM='#19151073' # fg-0 at 45% — a light scrim is ink, not black

# --- Tier 1: accent (§6.2) --------------------------------------------------
PHI_ACCENT='#8e5f6b'          # second lightness of #d3a0ac — 4.82:1 on bg-0
PHI_ACCENT_FG='#f6f5f3'

# --- Tier 2: semantic (§6.2) ------------------------------------------------
PHI_ERROR='#955e57'
PHI_ERROR_FG='#f6f5f3'
PHI_WARN='#806a37'
PHI_WARN_FG='#f6f5f3'
PHI_SUCCESS='#5d734c'
PHI_SUCCESS_FG='#f6f5f3'
PHI_INFO='#5a6e83'
PHI_INFO_FG='#f6f5f3'

# --- Tier 3: syntax (§6.2) --------------------------------------------------
# Same mapping onto existing hues as the dark variant, and the same caveat:
# six roles borrowing five colours until S-51 gives them their own.
PHI_SYNTAX_1='#8e5f6b'        # keyword          -> accent
PHI_SYNTAX_2='#5d734c'        # string           -> success
PHI_SYNTAX_3='#806a37'        # number, constant -> warn
PHI_SYNTAX_4='#5a6e83'        # function         -> info
PHI_SYNTAX_5='#955e57'        # type             -> error
PHI_SYNTAX_6='#746f66'        # operator, punct. -> fg-2

# --- Selection and terminal cursor (§6.2) -----------------------------------
PHI_SELECTION_BG='#e6e4e0'
PHI_SELECTION_FG='#191510'
PHI_CURSOR_TERM='#8e5f6b'

# --- ANSI 16 (§6.2, ADR 053) ------------------------------------------------
# The chromatic slots follow the dark variant's mapping exactly, so a tool
# themed for one variant is themed for the other. The four achromatic slots do
# not mirror it: slot 0 is "black" and slot 7 is "white" to the tools that use
# them, so they take this variant's darkest and lightest structural tones
# rather than the same token index the dark variant used. Mirroring the index
# would make `color0` render pale, and every tool that prints on it would
# disappear.
#
# The two defects of the dark map are inherited on purpose, so the two
# variants stay diffable: bright equals normal for every chromatic pair, and
# slot 6 collides with slot 4. S-51 fixes them in both files at once.
PHI_ANSI_0='#191510'          # black          -> fg-0
PHI_ANSI_1='#955e57'          # red            -> error
PHI_ANSI_2='#5d734c'          # green          -> success
PHI_ANSI_3='#806a37'          # yellow         -> warn
PHI_ANSI_4='#5a6e83'          # blue           -> info
PHI_ANSI_5='#8e5f6b'          # magenta        -> accent
PHI_ANSI_6='#5a6e83'          # cyan           -> info (collision, S-51)
PHI_ANSI_7='#c5c4c0'          # white          -> bg-3
PHI_ANSI_8='#746f66'          # bright black   -> fg-2
PHI_ANSI_9='#955e57'          # bright red
PHI_ANSI_10='#5d734c'         # bright green
PHI_ANSI_11='#806a37'         # bright yellow
PHI_ANSI_12='#5a6e83'         # bright blue
PHI_ANSI_13='#8e5f6b'         # bright magenta
PHI_ANSI_14='#5a6e83'         # bright cyan
PHI_ANSI_15='#e6e4e0'         # bright white   -> bg-1

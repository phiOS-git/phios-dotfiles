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
# PROVENANCE — S-50, the real derivation §6.2 requires ("si deriva
# algoritmicamente... in OKLCH"), executed and checked against `phi theme
# check` (zero violations, both variants — see phi/internal/theme/check.go).
# Every value below is one of:
#
#   [carried]   unchanged since the value that renders on zotac and razer
#               today. Changing one of these changes what the machines
#               display, so S-50 only touches the ones with a real reason to.
#   [derived]   computed this step: fixed OKLCH hue (H) and chroma (C) —
#               either carried forward from an existing anchor or a new one
#               for a slot that had none — with lightness (L) solved by
#               bisection against the *real* WCAG contrast formula
#               (phi/internal/tokens/color.go's Contrast, not an OKLab proxy:
#               §6.2's 4.5:1 is a WCAG AA figure and only means what it says
#               under WCAG's own math), then converted back to sRGB. The
#               solver also rejects any (L,C,H) whose linear-sRGB falls
#               outside [0,1] — no clipped, hue-shifted colour ever ships.
#   [filled]    a slot §6.2 requires that has no anchor of its own.
#               Interpolated in OKLab lightness along the ramp its neighbours
#               define. Gap-filling, not derivation.
#
# Every [carried]/[derived] OKLCH triple below was measured off the hex with
# the same conversion the solver uses (Björn Ottosson's OKLab, standard
# matrices) — not asserted, computed and printed.
#
#   token      role                      OKLCH (L, C, H)          hex
#   bg-0       structure, deepest        0.2142  0.0025   67.7°   #1a1918
#   bg-1       structure, +1             0.2561  0.0057   91.6°   #242320
#   fg-0       primary text              0.8624  0.0122   79.8°   #d6d1c9
#   fg-2 (old) secondary text/comments    0.5744  0.0148   82.4°  #7d786f
#   accent     Tier 1                    0.7566  0.0624    3.1°   #d3a0ac
#   error      Tier 2, oxide             0.6401  0.0741   28.0°   #b57b73
#   warn       Tier 2, ochre             0.7403  0.0745   85.9°   #c0a874
#   success    Tier 2, moss              0.6989  0.0639  132.6°   #8fa77e
#   info       Tier 2, slate             0.6603  0.0413  248.5°   #7f95ab
#
# STRUCTURE FIX (fg-1/fg-2/fg-3). §6.2 requires a uniform progression in
# perceptual luminance across fg-0..fg-3. The prior ramp forced fg-2 through
# fg-3's own hue/chroma anchor at L=0.574, which measures 4.00:1 against
# bg-0 — a real failure below the 4.5:1 floor, on today's running machines.
# Fixed by re-solving the ramp at fg-2's own (H=82.39°, C=0.0148): fg-0 stays
# the carried anchor (L=0.8624); the solver finds the L that puts fg-2 at
# 4.6:1 (a small margin above the floor, not the floor itself — the same
# margin every other checked pair in this file already carries); fg-1 and
# fg-3 fall out as the two remaining points of a *uniform* 4-point ramp
# through those same two fixed ends. fg-3 stays outside the 4.5:1 requirement
# by construction (non-text: dividers, disabled marks) but its ratio rose
# too, as a side effect of the wider, still-even spacing.
#
# CONTRAST, measured against bg-0 with `phi theme check`'s own formula:
#   fg-0 11.56:1   fg-1 7.50:1   fg-2 4.60:1   fg-3 2.73:1
#   accent 7.85:1  error 5.05:1  warn 7.60:1  success 6.69:1  info 5.68:1
# Every checked pair (fg-0/1/2, accent, error, warn, success, info — fg-3 is
# non-text by construction and excluded, same as §6.2 intends) now clears
# 4.5:1. `phi theme check` on this file reports zero violations.
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
PHI_FG_1='#aea99f'            # [derived] same H/C as fg-2, ramp point 1 of 4
PHI_FG_2='#878279'            # [derived] H=82.39° C=0.0148, solved for 4.6:1
PHI_FG_3='#635e55'            # [derived] same H/C as fg-2, ramp point 3 of 4

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
# diffs. S-50 derives each one on the same hue direction as the Tier 1/2
# role it disambiguates against, but at its OWN lightness — solved for a
# single shared syntax-legibility target (5.6:1 against bg-0, dark) instead
# of inheriting that role's own individual contrast. This is why every value
# below differs from its Tier 1/2 counterpart even though the hue is shared:
# a keyword no longer renders as the literal same hex as the accent used for
# focus rings, and all six syntax roles read as one consistent weight of ink
# rather than five different UI-element weights borrowed wholesale. Solved
# with the gamut-safety check documented above; syntax-2's chroma was backed
# off from success's own 0.0639 to 0.0579 — full chroma at this lightness
# fell outside sRGB.
PHI_SYNTAX_1='#b68490'        # keyword          -> accent hue,  H=3.06°   C=0.0624
PHI_SYNTAX_2='#829873'        # string           -> success hue, H=132.59° C=0.0579
PHI_SYNTAX_3='#a68f5b'        # number, constant -> warn hue,    H=85.85°  C=0.0745
PHI_SYNTAX_4='#7e94a9'        # function         -> info hue,    H=248.45° C=0.0413
PHI_SYNTAX_5='#bd837b'        # type             -> error hue,   H=27.99°  C=0.0741
PHI_SYNTAX_6='#878279'        # operator, punct. -> fg-2 (same token, no separate hue: muted ink, not a category)

# --- Selection and terminal cursor (§6.2) -----------------------------------
PHI_SELECTION_BG='#242320'    # [carried] kitty selection_background
PHI_SELECTION_FG='#d6d1c9'    # [carried] kitty selection_foreground
PHI_CURSOR_TERM='#d3a0ac'     # [carried] kitty cursor — separate from the GUI cursor

# --- ANSI 16 (§6.2, ADR 053) ------------------------------------------------
# This is the base16-style surface ADR 053 asks for: the sixteen slots every
# terminal tool assumes for errors, warnings, diffs and file types. It is not
# a second palette — every chromatic slot is one of the tokens above, or a
# derivation on the same anchor.
#
# S-50 fixes the two defects §6.2 flagged:
#   - Cyan (slot 6/14) collided with blue (slot 4/12) because nothing in
#     Tier 1/2/3 owns a cyan hue — info/slate sits at H=248° (blue-violet),
#     success/moss at H=132° (green). A genuinely new anchor, H=195°
#     (a teal-cyan, consistent with the retro/CAD chroma level of the other
#     anchors), sits between them and is used ONLY here — no other tier
#     references it, so it costs nothing to the four-hue Tier 2 direction.
#   - Bright was identical to normal for all six chromatic pairs. Fixed by
#     solving each bright slot on its normal slot's own hue at a HIGHER
#     chroma (roughly ×1.35, gamut-safety-checked the same way as Tier 3)
#     and a higher contrast target — more vivid AND more prominent, not
#     just relabelled.
# Achromatic slots (0/7/8/15) were not flagged and are untouched, still
# [carried]/[derived from fg-2] exactly as before (fg-2's own fix propagates
# into slot 8 automatically, since it is the same token).
PHI_ANSI_0='#242320'          # black          -> bg-1
PHI_ANSI_1='#b57b73'          # red            -> error
PHI_ANSI_2='#8fa77e'          # green          -> success
PHI_ANSI_3='#c0a874'          # yellow         -> warn
PHI_ANSI_4='#7f95ab'          # blue           -> info
PHI_ANSI_5='#d3a0ac'          # magenta        -> accent
PHI_ANSI_6='#3d9e9e'          # cyan           -> new anchor, H=195° C=0.09, solved 5.5:1
PHI_ANSI_7='#d6d1c9'          # white          -> fg-0
PHI_ANSI_8='#878279'          # bright black   -> fg-2 (S-50's fixed value)
PHI_ANSI_9='#d7897f'          # bright red     -> error hue, higher C, solved 6.5:1
PHI_ANSI_10='#87a76f'         # bright green   -> success hue, higher C, solved 6.5:1
PHI_ANSI_11='#bd9d53'         # bright yellow  -> warn hue, higher C, solved 6.8:1
PHI_ANSI_12='#809ebd'         # bright blue    -> info hue, higher C, solved 6.3:1
PHI_ANSI_13='#d292a2'         # bright magenta -> accent hue, higher C, solved 7.0:1
PHI_ANSI_14='#1eaaab'         # bright cyan    -> slot-6 hue, higher C, solved 6.2:1
PHI_ANSI_15='#d6d1c9'         # bright white   -> fg-0

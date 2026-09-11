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
#   PHI_RADIUS_SMALL/LARGE     1px/4px, OOP-02 (shell restyle) — two fixed
#   PHI_BORDER_WIDTH_STRONG    radii and a 2px panel border the restyle's
#   PHI_PANEL_PADDING          grammar needs and §6.3 does not cover. 4px
#                              panel padding, flat, not a 1ch multiple.
#   PHI_FONT_SCALE/SPACE_SCALE identity (1) by default, OOP-02 — the hook the
#                              settings panel's editable Theme section
#                              multiplies its per-user override through.
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
# ADR 125: does NOT conform to architettura §8.2.3's "sottile, nero
# bordato di bianco" (thin, black, white-outlined) — whiteglass is a WHITE
# cursor (xcursor-themes' other bundled option, redglass, is red; neither
# is black). Caught after first shipping this as "conforms" on a wrong
# assumption, corrected before handoff, and the user chose to accept this
# deviation rather than have a bespoke theme produced. A real, acknowledged
# gap from the written spec, not a fix — say so if this is ever revisited.
# One value for every consumer: Hyprland's own cursor, GTK, and Qt/the
# shell all resolve XCURSOR_THEME (hyprland.lua.tmpl's own S-54 note has
# the per-toolkit detail). Not variant-dependent, so it lives here rather
# than in tokens.dark.sh/tokens.light.sh.
PHI_CURSOR_THEME='whiteglass'
PHI_CURSOR_SIZE='24'

# --- Size scale (§6.3) ------------------------------------------------------
# Derived, not arbitrary: a 13px base at ~1.125 (major second), rounded to
# whole pixels and hand-tightened at the top so the seven steps stay close.
# Index 1 is the base; index 0 is the one step below it, which is why the
# scale does not start at the base. Two decisions are placeholders, the base
# and the ratio, and both are one line each.
#
# OOP-10 (shell restyle R2): base dropped 14px -> 13px and the upper steps
# pulled in, on the user's feedback that the shell read too large and the
# hierarchy too loud for a "minimal / developer" surface. Index 1 is also
# the cell-width basis for every `1ch` spacing in phi-shell, so this makes
# the whole GUI rhythm proportionally tighter, not just the text. Exact px
# per step is a judgment call — flagged for the screenshot pass.
PHI_FONT_SIZE_0='11px'
PHI_FONT_SIZE_1='13px'
PHI_FONT_SIZE_2='14px'
PHI_FONT_SIZE_3='16px'
PHI_FONT_SIZE_4='18px'
PHI_FONT_SIZE_5='21px'
PHI_FONT_SIZE_6='24px'

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

# radius-small / radius-large — OOP-02 (shell restyle). §6.3 fixes exactly
# one non-pill radius (radius-base), but the restyle's own grammar needs
# two more fixed points: the status bar's isles round at 1px (all but a
# sharp edge) and the runner rounds at 4px (deliberately softer than every
# other panel, shell doc §3). Neither is expressible as a multiple of
# radius-base, so they are their own tokens. Same fractional-HiDPI
# [PLACEHOLDER] caveat as radius-base.
PHI_RADIUS_SMALL='1px'
PHI_RADIUS_LARGE='4px'

# border-width has no home in §6.3's own token table — added at S-21, where
# the widget library found the gap: a separator, a panel border and a focus
# ring all need a stroke width, and DONE WHEN forbids a literal size in any
# widget. A hairline is a universal UI constant, not a design decision, so
# one token rather than a per-widget guess. [PLACEHOLDER] the same way
# radius-base is: unverified on real HiDPI/fractional-scaling output.
PHI_BORDER_WIDTH='2px'

# border-width-strong — OOP-02, retuned OOP-10. The restyle first drew
# every panel with a 2px opposite-colour border (a hard wireframe read);
# the user's R2 feedback, checked against references/panel-reference-*, is
# that the frame should be a hairline like every other stroke. Now 1px —
# equal to border-width. Kept as its own token because it is still a
# distinct ROLE (a surface's outline vs. a control's outline / a
# separator) and the two may diverge again; a consumer asking for the
# panel-frame width should not have to know it currently equals the
# hairline. Same [PLACEHOLDER] caveat.
PHI_BORDER_WIDTH_STRONG='1px'

# panel-padding — OOP-02, retuned OOP-10. Was a flat 4px; the references
# show the frame sitting well off its content. 8px — still a fixed frame,
# not a multiple of 1ch (the space-N scale is the rhythm for gaps BETWEEN
# elements; a panel's own edge inset is deliberately independent of the
# font's cell width). Exact value is a judgment call — flagged.
PHI_PANEL_PADDING='8px'

# panel-gap / panel-radius — Out-of-plan: features-change. The inset the
# below-the-bar surfaces keep from the bar and the screen edges (the
# notification and chat docks, the bar popouts, the calendar), and the
# corner radius those surfaces round at. Both per-user editable
# (settings › Theme › Shape & spacing). Same fractional-HiDPI [PLACEHOLDER]
# caveat as radius-base.
PHI_PANEL_GAP='2px'
PHI_PANEL_RADIUS='6px'

# slider-thickness — Out-of-plan: features-change. The visible track height
# of Widgets/Meter — the volume/brightness OSD and every in-shell slider —
# a thin rail, per references/overlay-reference.png. [PLACEHOLDER], same
# fractional-HiDPI caveat as radius-base.
PHI_SLIDER_THICKNESS='4px'

# --- User-tunable scale (OOP-02) ------------------------------------------
# Identity by default. The settings panel's Theme section (OOP-07) writes a
# per-user override for these into $XDG_STATE_HOME/phi/theme-overrides.json
# (never this file, never the repo — I-05: design/ stays the source of the
# DEFAULTS). font-scale multiplies the whole generated size scale; space-
# scale multiplies the whole spacing scale. Dimensionless factors, not a
# "size" in the I-05 sense — same latitude as the opacity ratio in
# phi-shell's Widgets/WidgetStates.js.
PHI_FONT_SCALE='1'
PHI_SPACE_SCALE='1'

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
# The same curve as four cubic-bezier control points (Out-of-plan: settings-
# overhaul batch E — the animation editor). '0.25,0.46,0.45,0.94' is the
# cubic-bezier equivalent of Qt's Easing.OutQuad, so nothing about the
# shipped motion changes until the user edits it. Consumed as
# easing.bezierCurve by every Behavior in phi-shell (Config/Appearance.qml
# motionBCurve appends the mandatory final (1,1) point).
PHI_MOTION_B_BEZIER='0.25,0.46,0.45,0.94'

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

# --- Wallpaper texture catalogue (Out-of-plan: settings-overhaul) -----------
# The procedural textures the shell's background layer can composite over the
# solid wallpaper colour. The list is a design decision (I-05) — which
# textures the system offers — so it lives here; `phi wallpaper texture`
# (phi/internal/wallpaper) is the generator and also validates the mode, and
# its own Modes slice MUST stay a superset of this list. Space-separated,
# menu order. Not a colour/font/size, so no [PLACEHOLDER] provenance applies
# beyond "this set was chosen, not measured".
PHI_TEXTURE_MODES='grain noise paper leather rock fabric'
PHI_TEXTURE_INTENSITY_DEFAULT='40'

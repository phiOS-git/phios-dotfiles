# design/

The single source of every colour, font, size, radius, motion value and
z-layer used anywhere in phiOS. Nothing outside this directory may contain
such a literal — not a configuration file, not a template, not QML (`I-05`).

```
tokens.common.sh   typography roles, size scale, spacing, radii, z-layers, motion A–D
tokens.dark.sh     palette, dark variant
tokens.light.sh    palette, light variant
adapters.txt       target: template, destination, reload command, class A/B/C
preview.tmpl       every token, rendered — the only consumer that exists yet
```

Both variants are permanent and generated together (`R6`); neither is a
derivative of the other at runtime.

## Format

`KEY=VALUE`, one per line, no command substitution and no conditionals, so the
files are sourceable by bash and parsable by Go with a line splitter and no
library (§6.1). Names are `PHI_` plus the abstract token name of §6.2/§6.3 in
upper snake case: `bg-0` is `PHI_BG_0`. Abstract only, never literal — there is
no `PHI_PINK` (ADR 060).

Units live in the value, as §6.3 writes them: `2px`, `120ms`, `1ch`. A consumer
that needs a bare number strips the suffix.

## Rendering

```
bin/phios-render [--variant dark|light] TEMPLATE [DESTINATION]
```

Substitutes the `PHI_*` names the token files define and nothing else, so a
`$PATH` or `$HOME` inside a configuration file survives untouched. The variant
defaults to the active runtime variant (`$XDG_STATE_HOME/phi/theme-variant`,
owned by the settings panel, §5.6) and to dark when none is set.

`bin/phios-install` renders `profiles/*/templates/*.tmpl` through the same
code path. Both are the bootstrap stand-in for `phi theme set`, which arrives
at S-12 and reads `adapters.txt` for destinations and reloads.

## What is provisional

Not the palette itself any more — S-50 derived it in OKLCH and `phi theme
check` (`phi/internal/theme/check.go`) reports zero violations on both
variants. Each file still says which of its values is which.

`tokens.dark.sh` is the palette that runs on `zotac` and `razer` today,
extended to the full §6.2 set. Values marked `[carried]` are ones that render
right now, unchanged by S-50. Values marked `[derived]` were computed by
S-50: a fixed OKLCH hue/chroma with lightness solved against the real WCAG
contrast formula, not chosen by eye. Values marked `[filled]` are slots
§6.2 requires that today's palette had no value for, interpolated along the
ramp its neighbours define.

`tokens.light.sh` has never rendered on a machine. All of it was constructed
at S-02 and re-derived at S-50; the file records exactly how, so a future
step can tell intent from accident.

`tokens.common.sh` opens with a `PLACEHOLDERS` block naming every value in it
that was invented rather than carried forward. `font-mono` was `Q-N01`,
closed this session: **Source Code Pro**. S-51 does the actual work
(package, fontconfig chain, kitty `symbol_map`, removing the patched font).

Contrast ratios are recorded next to the values in both palette files.
`phi theme check` passes with zero violations on both variants as of S-50.

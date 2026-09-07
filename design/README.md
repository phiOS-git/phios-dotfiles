# design/

The single source of every colour, font, size, radius, motion value and
z-layer used anywhere in phiOS. Nothing outside this directory may contain
such a literal — not a configuration file, not a template, not QML (`I-05`).

Empty until **S-02**, which adds:

```
tokens.common.sh   typography roles, spacing scale, radii, z-layers, motion A–D
tokens.dark.sh     palette, dark variant
tokens.light.sh    palette, light variant
adapters.txt       target: template, destination, reload command, class A/B/C
```

Both variants are permanent and generated together (`R6`); neither is a
derivative of the other.

`bin/phios-install` already renders `profiles/*/templates/*.tmpl` against these
files, substituting only the `PHI_*` names they export. Until they exist, a
profile that ships a template is a hard error rather than a silent
half-render.

# phiOS — compatibility shim for the pre-M0 installer. Removed at S-03.
#
# This file used to be the palette: nine hex literals, exported for install.sh
# to render the *.tmpl files in modules/ with. S-02 moved every one of them
# into design/, which is now the single source (I-05, master plan §6.1). What
# is left here is a translation layer and nothing else — there is no colour in
# this file, and there must never be one again.
#
# It exists because install.sh is still the live installer on zotac and razer
# until S-03 migrates modules/ into profiles/. Deleting the nine names today
# would render every *.tmpl in modules/ with empty values the next time the
# user runs install.sh. So the names survive, and the values behind them come
# from the tokens.
#
# The mapping is the same one recorded in design/tokens.dark.sh under
# PROVENANCE, read in the other direction. It is exact, so install.sh writes
# the same bytes it wrote before S-02 — which is what makes S-03's
# output-identical migration something that can be checked rather than
# asserted.
#
# S-03 migrates the templates in modules/ to the token names directly and
# deletes this file. Nothing new may be added to it in the meantime.

_phios_theme_sh_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
_phios_theme_sh_variant=${PHIOS_VARIANT:-}

if [ -z "$_phios_theme_sh_variant" ]; then
	if [ -r "${XDG_STATE_HOME:-$HOME/.local/state}/phi/theme-variant" ]; then
		read -r _phios_theme_sh_variant < "${XDG_STATE_HOME:-$HOME/.local/state}/phi/theme-variant" || _phios_theme_sh_variant=''
	fi
fi
[ -n "$_phios_theme_sh_variant" ] || _phios_theme_sh_variant=dark

. "$_phios_theme_sh_dir/design/tokens.common.sh"
. "$_phios_theme_sh_dir/design/tokens.$_phios_theme_sh_variant.sh"

# Four of the nine pre-M0 names were renamed by §6.2 and are translated here.
PHI_BG="$PHI_BG_0"
PHI_SURFACE="$PHI_BG_1"
PHI_FG="$PHI_FG_0"
PHI_FG_DIM="$PHI_FG_2"

# The other five kept their names: accent, error, warn, success and info are
# already the §6.2 token names, so the token files define them directly and
# there is nothing to translate.

export PHI_BG PHI_SURFACE PHI_FG_DIM PHI_FG PHI_ACCENT
export PHI_ERROR PHI_WARN PHI_SUCCESS PHI_INFO

unset _phios_theme_sh_dir _phios_theme_sh_variant

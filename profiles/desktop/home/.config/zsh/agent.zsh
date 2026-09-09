# phiOS — AI agent shell helpers (desktop profile, S-76, revised by
# phios-agente-delta.md D-03).
#
# `phi-code [DIR]` starts a contained A2 opencode session (the worker agent,
# docs/phios-agente.md §3.1) in DIR — any directory, not a fixed code root.
# DIR (default $PWD) becomes the ONLY thing under $HOME the session can see,
# mounted read-write at /home/agent/work. A configurable blocklist
# (~/.config/phi-agent/code-blocklist) guards the picker.
#
# Inside the session there are NO SSH keys, NO gpg, NO push to remotes: A2
# edits and commits locally, and publishing is your action afterward (§4.4,
# ADR 089). Network is the S-72 whitelist only.
#
# This is a thin wrapper over `phi agent code`, which does the validation,
# records the session metadata the shell panel reads, and exec's
# phi-agent-contain.

phi-code() {
	emulate -L zsh
	local dir=${1:-$PWD}
	command phi agent code "${dir:A}"
}

# `phi-ask` is just a shorter alias for the inline A1 question (§10.2).
alias phi-ask='phi agent ask'

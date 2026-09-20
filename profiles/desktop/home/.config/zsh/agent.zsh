# phiOS — AI agent shell helpers.
#
# `phi-code [DIR]` starts a contained A2 opencode session (the worker agent)
# in DIR — any directory, not a fixed code root.
# DIR (default $PWD) becomes the ONLY thing under $HOME the session can see,
# mounted read-write at /home/agent/work. A configurable blocklist
# (~/.config/phi-agent/code-blocklist) guards the picker.
#
# Inside the session there are NO SSH keys, NO gpg, NO push to remotes: A2
# edits and commits locally, and publishing is your action afterward. Network
# is restricted to a whitelist only.
#
# This is a thin wrapper over `phi agent code`, which does the validation,
# records the session metadata the shell panel reads, and exec's
# phi-agent-contain.

phi-code() {
	emulate -L zsh
	local dir=${1:-$PWD}
	command phi agent code "${dir:A}"
}

# `phi-ask` is a shorter alias for inline A1 questions.
alias phi-ask='phi agent ask'

# phios-dotfiles

**Configuration only.** No compiled code, no application source.

- `design/` is the single source of every colour, font, size, radius and motion value. Nothing outside it may contain a literal (`I-05`).
- `profiles/*/system/` holds `/etc` material. It is **shown** by `--system-diff` and **never applied** by the installer. Applying it is a user action, with `sudo`, file by file.
- `profiles/*/services-*.txt` **declare** systemd units. The installer prints them; it never enables them.
- Package installation order inside `hosts/<host>.txt` is significant: a profile providing a concrete provider must precede one requiring it. Regression to avoid: on `razer`, `gaming` before `razer-hw` produced an interactive prompt for `vulkan-driver`.
- `PROGRESS.md` is the durable memory of the step loop. Update it in the same commit as the step.
- Bootstrap scripts are bash, and may depend only on coreutils, bash, git and gettext. They must run on a freshly installed machine, before `phi` exists.
- The installer must be idempotent, must support `--dry-run`, and must reconcile against the state manifest so that a file removed from the repo is removed from the machine.

# ~/.config/phi-agent/

Configuration for the phiOS AI agent subsystem. `zotac` and `razer` only —
`mini` does not carry the `desktop` profile.

The engine is [pi](https://pi.dev) (`@earendil-works/pi-coding-agent`), run
`--mode rpc`, in print mode, or as its interactive terminal UI — never
unconfined. Every launch goes through `~/.local/bin/phi-agent-contain`,
which builds a bubblewrap containment from empty for one of four profiles:

| Profile | Chat in panel | pi tools | Broker instance / net class | Writable (besides the ephemeral agent-dir tmpfs) |
|---|---|---|---|---|
| `general` | yes | read, write, edit, grep, find, ls | a1 — host network, `http://127.0.0.1:8789` | project `output/`, `proposte/` of system, profile and project level, session dir |
| `academic` | yes | read, write, edit, grep, find, ls | a1 | same as general |
| `coding` | no (terminal TUI only) | read, bash, edit, write, grep, find, ls | a2 — `--unshare-net`, `http://127.0.0.1:8790` via socat forwarder, egress proxy | the workdir, rw project folders, session dir |
| `inline` | no | none | a1 | nothing (no session dir) |

Broker instances stay `a1` (serves general, academic, inline) and `a2`
(serves coding) — the broker code and its config layout are unrelated to
the four pi profiles above and do not change with them.

## Files

| Path | What | Who edits |
|---|---|---|
| `env.example` | template for the local config | — |
| `~/.config/phi-agent/env` | **you create this** from the example: git identity and the coding toolchain cache | you |
| `code-blocklist.example` | template for the coding / folder-of-interest blocklist | — |
| `~/.config/phi-agent/code-blocklist` | **you create this** from the example: directories `phi agent code` and the folder picker refuse (a guard-rail, not the boundary) | you (also Settings › AI Agent) |
| `mounts/common.paths` | read-only base for every profile | repo |
| `mounts/assistant.paths` | perimeter for general, academic, inline | repo |
| `mounts/coding.paths` | perimeter for coding | repo |
| `mounts/never.paths` | the checklist of paths that must stay unreachable | repo |
| `pi/env` | pi's own process environment (`PI_OFFLINE`, `PI_SKIP_VERSION_CHECK`, `PI_TELEMETRY`) | repo |
| `pi/profiles/<profile>/settings.json` | pi settings for that profile | repo |
| `pi/profiles/<profile>/SYSTEM.md` | that profile's system prompt | repo |
| `pi/profiles/<profile>/trust.json` | an empty project-trust store, bound read-only so no session can trust its own working directory (an entry there would override `defaultProjectTrust: "never"`) | repo |
| `pi/profiles/<profile>/models.example.json` | template naming the broker as the provider's endpoint | repo |
| `~/.config/phi-agent/pi/profiles/<profile>/models.json` | **you create this** from the example: name the real provider | you |
| `pi/extensions/phi-workflow.ts` | first-party extension, see "Extensions" below | repo |
| `<inst>/broker.example.json` | template for the broker config | — |
| `~/.config/phi-agent/<inst>/broker.json` | **you create this**: provider origin + how the key attaches (no key) | you |
| `~/.config/phi-agent/<inst>/provider-key` | **you create this**, `chmod 600`: the raw provider API key | you |
| `tinyproxy/tinyproxy.conf` | coding profile's egress whitelist proxy config | repo |
| `tinyproxy/whitelist` | the whitelist itself | repo (you uncomment entries) |

## Extensions

`pi/extensions/phi-workflow.ts` is a first-party pi extension: it ships from
this repository rather than being installed from a package registry, so it
needs no separate declaration under the tier ladder. It is reached by
`general`, `academic` and `coding` through a relative symlink in each
profile's own `pi/profiles/<profile>/extensions/`; `inline` runs with
`--no-extensions` and never loads it.

It registers three tools that the shell panel's agent view renders with
dedicated cards:

| Tool | Does |
|---|---|
| `plan` | Replaces the session's plan (an ordered checklist with a status per step) and shows it as a widget above the editor. |
| `subagent` | Runs one task in an isolated, non-interactive child `pi` process and streams its progress back. |
| `ask_user` | Asks the user a question through pi's own select/input dialogs and returns their answer. |

Every other tool renders generically; nothing in the panel or in pi itself
requires this extension to be present.

## The broker

pi never sees the provider key. A profile's `models.json` names a provider
whose `baseUrl` is `http://127.0.0.1:8789` (a1) or `http://127.0.0.1:8790`
(coding, a2) with a dummy `apiKey` ("broker") — pi only needs a non-empty
key to treat the provider as usable; the real one lives with `phi agent
broker`, which runs *outside* the containment, holds the key, and adds it
to the outbound request. The broker appends the incoming request path
unchanged, so `baseUrl` must already carry any path segment the provider's
own API expects (`/v1` for an OpenAI-compatible endpoint, for example) — a
`baseUrl` missing that path fails as a silent 404, not a clear error.

Set it up, per instance (a1 first):

```
cd ~/.config/phi-agent/a1
cp broker.example.json broker.json
$EDITOR broker.json          # set upstream (provider ORIGIN, no path) and auth_header/auth_value
printf '%s' 'sk-...your-key...' > provider-key && chmod 600 provider-key
phi agent broker --instance a1 --check     # must print a summary and exit 0
systemctl --user enable --now phi-agent-broker@a1.service
```

Then, per profile that uses that instance:

```
cd ~/.config/phi-agent/pi/profiles/general
cp models.example.json models.json
$EDITOR models.json          # replace REPLACE-WITH-PROVIDER with the real provider id
```

For a provider that only speaks Anthropic's native `/v1/messages`, set
`auth_header` to `x-api-key` in `broker.json`, `auth_value` to `{key}`, and
add `"anthropic-version": "2023-06-01"` to `extra_headers`.

Consumption is logged as JSONL at
`~/.local/state/phi-agent/<inst>/broker-meter.jsonl`. The broker also
enforces a local fixed-window request limit (`rate_limit` in
`broker.json`).

## The coding profile's network

Coding runs with `--unshare-net`: a fresh namespace, only a down loopback,
no route anywhere. Two unix sockets in `~/.local/state/phi-agent/net/`,
bind-mounted into the container, are the only way out:

| socket | to | purpose |
|---|---|---|
| `broker-a2.sock` | `phi-agent-broker@a2` | the provider call; created by the broker unit itself |
| `proxy.sock` | `tinyproxy` via `phi-agent-net-bridge` | everything else, filtered by `tinyproxy/whitelist` |

`phi-agent-contain` runs two `socat` forwarders inside the namespace that
turn those sockets into `127.0.0.1:8790` (broker) and `127.0.0.1:8118`
(proxy), and sets `HTTP(S)_PROXY` to the latter. A process that unsets the
proxy variables is left able to reach only the broker — never the free
network.

**The whitelist grows only by explicit addition.** `tinyproxy/whitelist`
ships with loopback allowed and every package registry commented out;
uncomment exactly the ones a project on this machine actually fetches from.

Enable (only when coding is in use):

```
systemctl --user enable --now phi-agent-proxy.service phi-agent-net-bridge.service
```

### Do this at the provider, not here

- **Set a hard spending cap on the API key.** It is the only measure that
  limits damage rather than probability: a compromised agent can spend against
  the key until you revoke it, but not steal it.
- **Write the revocation procedure down now**, before you need it: the
  provider's key-management URL, and the exact steps to disable this key.
  Keep it somewhere you can reach without this machine.

The launcher is `~/.local/bin/phi-agent-contain`. Everything — the systemd
units, `phi agent ask`, `phi agent code` — goes through it; there is no way
to start an agent outside the containment.

## Data layout

```
~/.local/share/phi-agent/                DATA ROOT
    memoria.md                           system memory level
    proposte/                            system proposals
    profiles/<profile>/memoria.md        profile memory level (general, academic, coding)
    profiles/<profile>/proposte/
    sessions/                            transcripts of sessions with no project
    projects/<name>/
        project.json
        instructions.md                  generated from project.json by phi, never hand-edited
        memoria.md
        proposte/
        allegati/                        attachments (static copies)
        sessions/                        transcripts of this project's sessions (any profile)
        output/

~/.local/state/phi-agent/
    a1/ a2/                              broker state and meters
    net/                                 coding's bridge sockets
    terminal/<id>.json                   records of terminal TUI sessions (`phi agent code`/`tui`)
~/.cache/phi-agent/<profile>/            per-profile cache, rw in the container at /home/agent/.cache
```

Memory has three levels — **system**, **profile**, **project** — each a
`memoria.md` mounted **read-only** into the containment (the agent cannot
write its own memory at any level) with its own writable `proposte/`, and
only for general and academic. You promote a proposal:

```
phi agent memory list-all
phi agent memory show FILE --level profile --profile general
phi agent memory accept FILE --level project --project notes   # append to that level's memoria.md
phi agent memory reject FILE --level system
```

Projects have no "active" state any more — a project is a per-session
parameter, passed with `--project` wherever it applies:

```
phi agent project new notes
phi agent project folder add notes ~/Notes --mode ro           # a read-only folder of interest
phi agent project show notes
phi agent code ~/dev/some-project --project notes               # or: phi agent ask --project notes "..."
```

A folder's host path is per-machine (`project.json`'s `folders[].paths`
maps hostname → path), so the same project can point at different real
directories on `zotac` and `razer`. `mode` is `ro` or `rw`; `rw` is only
ever honoured for the coding profile — every other profile mounts a `rw`
folder read-only regardless.

## How sessions start

| Use | Command |
|---|---|
| Shell panel chat (general, academic) | `phi-agent.service` runs `phi agent serve`, which spawns a contained `pi --mode rpc` per live session |
| Interactive terminal, general/academic | `phi agent tui` (alias `phi-chat`) |
| Coding, interactive terminal | `phi agent code DIR` (alias `phi-code`) |
| One-off question, general/academic | `phi agent ask "..."` (alias `phi-ask`) |
| Editor inline rewrite | `phi agent inline`, stdin `{"instruction","text","filetype"}`, stdout the replacement text only |

`phi agent ask` sends one question to a throwaway session and prints the
reply: it never shows in the panel list and never reaches memory. It needs
`phi-agent.service` up; it never starts an engine of its own.

```
phi agent ask "explain container isolation"
phi agent ask --profile academic "summarise this argument"
```

`phi-agent.service` runs `phi agent serve`, listening on `127.0.0.1:4199`
(loopback, no auth — a second, authenticated tailnet listener is designed
for but **not implemented yet**; there is currently no remote access to
any profile from another of your devices).

## Verification checklist (PI-04)

Run a real coding session and confirm, from inside it:

```
cat ~/.ssh/id_*          # fails — no such file
git push                 # fails — no route to a forge
git commit               # works — coding may commit locally
echo x >> ~/.pi/agent/settings.json   # fails — read-only
echo x > ~/.pi/agent/extensions/x     # fails — the subdirectory is remounted read-only
echo x > ~/.pi/agent/trust.json       # fails — read-only
mkdir -p ~/.agents/skills/x           # fails — ~/.agents is an empty read-only mount
echo x > ~/.pi/agent/scratch          # succeeds, but the file is gone on the next launch —
                                       # the agent-dir root is an ephemeral tmpfs, not persistent storage
```

The session is recorded under `~/.local/state/phi-agent/terminal/` for the
shell panel's coding-sessions view.

## Migration from the opencode agent

`phi agent init` migrates legacy data **non-destructively** (copy, never
delete) from `~/.local/share/phi-agent/a1/` into the new data root.

1. Stop and remove the old units, then enable the new one:
   ```
   systemctl --user disable --now phi-agent-a1.service phi-agent-a2.service \
       phi-agent-a2-remote.service phi-agent-a2-remote-engine.service
   systemctl --user enable --now phi-agent.service
   ```
2. Run `phi agent init`.
3. For each profile you use, create its `models.json` from
   `models.example.json` (see "The broker" above) and set the provider.
4. Retire the old engine's local configuration once a real session
   completes cleanly:
   ```
   mv ~/.config/opencode ~/.config/opencode.pre-phios.bak
   ```
   opencode itself stays installed as an unrelated standalone tool; only its
   configuration for the old agent setup is retired here.

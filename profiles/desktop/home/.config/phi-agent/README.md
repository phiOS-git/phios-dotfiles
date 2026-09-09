# ~/.config/phi-agent/

Configuration for the phiOS AI agent subsystem (`docs/phios-agente.md` +
`docs/phios-agente-delta.md`). `zotac` and `razer` only — `mini` does not
carry the `desktop` profile.

Two opencode instances, separated by capability and by containment:

| | A1 — assistant | A2 — worker |
|---|---|---|
| shell | no | yes |
| writes | `output/` + `proposte/` of the active project, and `proposte/` of every memory level | the one directory you open it in |
| network | host namespace, fetch approved interactively | removed, then a whitelist (S-72) |
| memory | proposes at three levels, never writes | none |

## Files

| Path | What | Who edits |
|---|---|---|
| `env.example` | template for the local config | — |
| `~/.config/phi-agent/env` | **you create this** from the example: git identity, optional A2 toolchain cache and remote address | you |
| `code-blocklist.example` | template for the A2 / folder-of-interest blocklist | — |
| `~/.config/phi-agent/code-blocklist` | **you create this** from the example: directories `phi agent code` and the folder picker refuse (a guard-rail, not the boundary) | you (also Settings › AI Agent) |
| `mounts/common.paths` | read-only base for both instances (§4.2) | repo |
| `mounts/a1.paths` | A1 perimeter (§4.3) | repo |
| `mounts/a2.paths` | A2 perimeter (§4.4) | repo |
| `mounts/never.paths` | the V-01/V-02 checklist of paths that must stay unreachable | repo |
| `<inst>/opencode/opencode.example.json` | template for the engine config — provider `phi-broker` on loopback, hardening permissions | — |
| `~/.config/phi-agent/<inst>/opencode/opencode.json` | **you create this** from the example: set the model id (two places) | you |
| `<inst>/broker.example.json` | template for the broker config | — |
| `~/.config/phi-agent/<inst>/broker.json` | **you create this**: provider origin + how the key attaches (no key) | you |
| `~/.config/phi-agent/<inst>/provider-key` | **you create this**, `chmod 600`: the raw provider API key | you |
| `tinyproxy/tinyproxy.conf` | A2 egress whitelist (S-72) | repo |

## The broker (S-71, phios-agente.md §6.2)

opencode never sees the provider key. Its `phi-broker` provider talks
**in clear over loopback** to `phi agent broker`, which runs *outside* the
containment, holds the key, and adds it to the outbound request.

Set it up, per instance (a1 first):

```
cd ~/.config/phi-agent/a1
cp broker.example.json broker.json
$EDITOR broker.json          # set upstream (provider ORIGIN, no path) and auth_header/auth_value
printf '%s' 'sk-...your-key...' > provider-key && chmod 600 provider-key
cp opencode/opencode.example.json opencode/opencode.json
$EDITOR opencode/opencode.json   # replace REPLACE-WITH-YOUR-MODEL-ID (two places)
phi agent broker --instance a1 --check     # must print a summary and exit 0
systemctl --user enable --now phi-agent-broker@a1.service
```

`opencode.json` ships assuming an **OpenAI-compatible** provider
(`@ai-sdk/openai-compatible`, requests to `/v1/chat/completions`). For a
provider that only speaks Anthropic's native `/v1/messages`, change
`provider.phi-broker.npm` to `@ai-sdk/anthropic`, set `options.baseURL` to
`http://127.0.0.1:8789` (no `/v1`), and in `broker.json` set
`auth_header` to `x-api-key`, `auth_value` to `{key}`, and add
`"anthropic-version": "2023-06-01"` to `extra_headers`.

Ports: a1 broker `127.0.0.1:8789`, a2 broker `127.0.0.1:8790`.

Consumption is logged as JSONL at
`~/.local/state/phi-agent/<inst>/broker-meter.jsonl`. The broker also
enforces a local fixed-window request limit (`rate_limit` in
`broker.json`).

## A2's network (S-72, phios-agente.md §5.1)

A2 runs with `--unshare-net`: a fresh namespace, only a down loopback, no
route anywhere. Two unix sockets in `~/.local/state/phi-agent/net/`,
bind-mounted into the container, are the only way out:

| socket | to | purpose |
|---|---|---|
| `broker-a2.sock` | `phi-agent-broker@a2` | the provider call (§6.2); created by the broker unit itself |
| `proxy.sock` | `tinyproxy` via `phi-agent-net-bridge` | everything else, filtered by `tinyproxy/whitelist` |

`phi-agent-contain` runs two `socat` forwarders inside the namespace that
turn those sockets into `127.0.0.1:8790` (broker) and `127.0.0.1:8118`
(proxy), and sets `HTTP(S)_PROXY` to the latter. A process that unsets the
proxy variables is left able to reach only the broker — never a free
network (that is V-03).

**The whitelist grows only by explicit addition.** `tinyproxy/whitelist`
ships with loopback allowed and every package registry commented out;
uncomment exactly the ones a project on this machine actually fetches from.

Enable (only when A2 is in use, from S-76):

```
systemctl --user enable --now phi-agent-proxy.service phi-agent-net-bridge.service
```

### Do this at the provider, not here

- **Set a hard spending cap on the API key.** It is the only measure that
  limits *damage* rather than probability (§6.3): a compromised agent can
  spend against the key until you revoke it, but not steal it.
- **Write the revocation procedure down now**, before you need it: the
  provider's key-management URL, and the exact steps to disable this key.
  Keep it somewhere you can reach without this machine.

The launcher is `~/.local/bin/phi-agent-contain`. Everything — the systemd
units, `phi agent ask` — goes through it; there is no way to start an agent
outside the containment (§4.7).

## Not managed here

- The provider API key: held by `phi agent broker` outside the containment,
  read from its own file (S-71).
- The remote-surface password: a systemd credential from a root-owned file
  outside the repository (S-74).
- Personalities and projects: the §8.2 data model under
  `~/.local/share/phi-agent/a1/`. Bootstrapped by `phi agent init` (two
  seed personalities, no projects). Managed with `phi agent project` and
  `phi agent personality`, or from the shell's agent panel.

## The data model and the engine (S-73, revised by phios-agente-delta.md)

```
phi agent init                       # seed personalita/general/ + technical/ (migrates the old flat *.md)
phi agent project new notes --folder ~/Notes --personality notes   # a project = a folder + metadata
phi agent project use notes          # set active + restart phi-agent-a1 so the containment is rebuilt for it
phi agent project folder add notes ~/Reference   # a read-only folder of interest (not copied)
phi agent personality new notes --from-file ./notes-personality.md
```

A project owns `project.json` (title, description, instructions, default
personality, folders of interest, pins); `progetto.md` and `folders.list`
are regenerated from it. Materials are static copies; folders of interest
are the real directory, mounted **read-only** (delta D-02).

Memory has three levels — **system**, **personality**, **project** — each a
`memoria.md` mounted **read-only** into the containment (the agent cannot
write its own memory at any level — §8.4 / delta D-01) with its own writable
`proposte/`. You promote a proposal:

```
phi agent memory list  --level system                         # or personality/project
phi agent memory show FILE --level personality --personality notes
phi agent memory accept FILE --level project                  # append to that level's memoria.md
phi agent memory reject FILE --level system
```

The `phi` MCP server (`phi agent mcp`, one read-only tool `phi_context`) is
registered in `a1/opencode/opencode.json` and spawned by opencode inside
the containment. It is tool 5 and the only place the agent's capabilities
grow (§7.1).

A1 runs as `phi-agent-a1.service` on `127.0.0.1:4199`.

## Inline questions and the remote surface (S-74)

`phi agent ask "..."` sends one question to the running A1 service and
prints the reply. It creates an opencode session, uses it, and **deletes
it** — so it never shows in the panel list and never reaches memory
(§10.2). It needs `phi-agent-a1.service` up; it never starts an engine.

```
phi agent ask "what does ADR 094 say?"
phi agent ask --personality technical "explain this bwrap flag: --unshare-cgroup"
```

The **remote surface** is A2 only, and off by default (§10.3). Three units:

| unit | role |
|---|---|
| `phi-agent-a2.service` | local contained A2, loopback, no password |
| `phi-agent-a2-remote-engine.service` | A2 with the password + an inbound socket — starting it *is* "declaring the session remote" |
| `phi-agent-a2-remote.service` | the overlay listener; the only thing that binds `PHI_AGENT_REMOTE_ADDR`, and only that address |

For a remote session:

```
# one-time: the address and the password
echo 'PHI_AGENT_REMOTE_ADDR=<this-machine-overlay-address>' >> ~/.config/phi-agent/env
printf '%s' '<a strong password>' > ~/.config/phi-agent/a2/remote-password && chmod 600 ~/.config/phi-agent/a2/remote-password

# per session:
systemctl --user start phi-agent-a2-remote.service    # pulls in the engine
# ... connect from another of your devices on the overlay, port 4399, user "phi" ...
systemctl --user stop phi-agent-a2-remote.service phi-agent-a2-remote-engine.service
```

Overlay reachability is the overlay's own default-deny policy — allow only
your own devices toward port 4399. No extra encryption layer (the overlay
already encrypts).

## Transition from unconfined opencode (S-76)

Do this only after V-01…V-04 and V-08/V-09 have passed. It removes the
agent's access to your SSH keys and its ability to push — A2 commits
locally, you publish.

1. Enable the A2 support services:
   ```
   systemctl --user enable --now phi-agent-broker@a2.service phi-agent-proxy.service phi-agent-net-bridge.service
   ```
   and set up `~/.config/phi-agent/a2/broker.json` + `provider-key`, copy
   `a2/opencode/opencode.example.json` to `opencode.json` and set the model
   id, and uncomment the registries your projects need in
   `tinyproxy/whitelist`.

2. Use `phi-code` (or `phi agent code DIR`) for coding sessions instead of
   bare `opencode`. It opens in **any** directory — that directory is the
   only thing under `$HOME` the session sees, mounted read-write at
   `/home/agent/work`; `~/.config/phi-agent/code-blocklist` guards the
   picker.
   ```
   cd ~/dev/some-project
   phi-code                       # == phi agent code "$PWD"
   ```
   Run a **real** task and let it finish. Confirm from inside:
   `cat ~/.ssh/id_*` fails, `git push` fails (no route to a forge), and
   `git commit` works. Publish afterward from your normal shell.
   The session is recorded under `~/.local/state/phi-agent/a2/sessions/`
   for the shell panel's Coding-sessions view (delta D-07).

3. Once a real session completes cleanly, retire the old config:
   ```
   mv ~/.config/opencode ~/.config/opencode.pre-phios.bak
   ```
   Keep the backup until you are sure `phi-code` covers everything you
   used opencode for. The step is done when the unconfined configuration
   is gone.

`phi-agent-a2.service` (plain loopback serve) is optional — a persistent
server for tooling that speaks opencode's HTTP API. Reaching its port from
the host needs a bridge you add yourself; day-to-day interactive use is
`phi-code`.

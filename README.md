# ai-skills

A [Claude Code](https://claude.com/claude-code) plugin bundling custom skills. Each skill
teaches Claude a repeatable workflow — when to use it, how to do it, and what output to produce.

## Install

```
/plugin marketplace add SpaceCafe/ai-skills
/plugin install ai-skills
```

or from the CLI:

```
claude plugin marketplace add SpaceCafe/ai-skills
claude plugin install ai-skills
```

Plugins auto-update in the background; a notification tells you when a reload (`/reload-plugins` or restart) is needed
to pick up the new version.

Disable the whole plugin per-project with `claude plugin disable ai-skills -s project`.
To disable one skill without touching the rest, add a deny rule to that project's
`.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Skill(ai-skills:skill-name)"
    ]
  }
}
```

## Skills

| Skill                                                          | Use when                                                                                                                                                                           |
|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`triage-github-issues`](skills/triage-github-issues/SKILL.md) | Triaging new GitHub issues — labels, assigns, checks for related issues, and posts an assessment comment for a human to approve. Safe to re-run; never implements anything itself. |

## Structure

```
.claude-plugin/
├── plugin.json       plugin manifest (name, description, author)
└── marketplace.json  lets this repo be added directly via `plugin marketplace add`
.mcp.json             MCP servers bundled with the plugin (currently: deepwiki, github)
skills/<skill-name>/
├── SKILL.md          required — frontmatter (name, description) + instructions
├── scripts/          optional — executable code for deterministic tasks
├── references/       optional — docs loaded into context only when needed
└── assets/           optional — files used directly in output (templates, icons, ...)
```

### MCP servers

`.mcp.json` at the plugin root is keyed by server name directly — no `mcpServers`
wrapper (that wrapper is only for project-level `.mcp.json` / desktop configs). A
local server binary should be referenced via `${CLAUDE_PLUGIN_ROOT}`, which Claude
Code substitutes with the plugin's install path:

```json
{
  "my-server": {
    "command": "node",
    "args": [
      "${CLAUDE_PLUGIN_ROOT}/mcp-server/index.js"
    ]
  }
}
```

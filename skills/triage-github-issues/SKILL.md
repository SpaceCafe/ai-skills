---
name: triage-github-issues
description: 'Triage GitHub issues using gh, the REST API, or MCP tools. Use this whenever the user asks to "triage issues," "check for new issues," "go through the issue tracker," or similar — including a bare "/triage-issues." Only touches issues that have no `status:*` label yet, so it is always safe to re-run. Does not implement anything — that is a separate step that only happens after a human has reviewed and approved each triaged issue on GitHub.'
---

# Triage GitHub Issues

Triage GitHub issues using `gh`, the GitHub REST API, or GitHub's official MCP server (`github-mcp-server`,
tools prefixed `mcp__github__`) — whichever is available.

Turns a raw GitHub issue into something a human can approve at a glance: the right labels, an owner, and three sentences
saying whether it's a quick win or a can of worms. It does not write any code — that's deliberately a separate step,
gated on a human looking at the triage comment and deciding "yes, go" or "let's talk first" on GitHub itself.

## Why it's split this way

Analysis is cheap and safe to automate. Deciding what actually gets built is not — that's a judgment call the repo owner
should make with full context, at whatever pace suits them (could be five minutes later, could be next week). Triaging
every new issue immediately, but never starting work without an explicit go-ahead, is what lets this run unattended on
the triage half without ever surprising anyone with an unwanted PR.

## Available Tools

### MCP Tools (read operations)

| Tool                         | Purpose                                                                                                   |
|------------------------------|-----------------------------------------------------------------------------------------------------------|
| `mcp__github__issue_read`    | Read issue details, sub-issues, comments, labels (methods: get, get_comments, get_sub_issues, get_labels) |
| `mcp__github__list_issues`   | List and filter repository issues by state, labels, date                                                  |
| `mcp__github__search_issues` | Search issues across repos using GitHub search syntax                                                     |
| `mcp__github__get_label`     | Get a specific label's details (color, description) from a repository                                     |
| `mcp__github__list_label`    | List all labels defined on a repository                                                                   |

### MCP Tools (write operations)

| Tool                             | Purpose                                                                                                                         |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| `mcp__github__issue_write`       | Create or update an issue (methods: create, update). Supports title, body, type, labels, assignees, milestone, and issue fields |
| `mcp__github__add_issue_comment` | Add a comment or a reaction to an issue                                                                                         |
| `mcp__github__sub_issue_write`   | Add, remove, or reprioritize a sub-issue                                                                                        |
| `mcp__github__label_write`       | Create, update, or delete a label (methods: create, update, delete)                                                             |

### CLI / REST API (write operations)

`gh api` and `gh` subcommands perform the same writes and are the form used throughout this skill. Reach for them when
the MCP server is not connected, or when you need a field the MCP tools do not expose. Each Workflow step below already
gives its specific `gh` / MCP / REST forms — this table is just a generic fallback.

| Operation    | Command                                                                                   |
|--------------|-------------------------------------------------------------------------------------------|
| Update issue | `gh api repos/{owner}/{repo}/issues/{number} -X PATCH -f labels[]=... -f assignees[]=...` |
| Add comment  | `gh api repos/{owner}/{repo}/issues/{number}/comments -X POST -f body=...`                |

## One-time setup: labels

This skill leans on a small label taxonomy. Check existing labels first, and create any that are missing (idempotent —
safe to check every run):

| Label                 | Color    | Meaning                                         |
|-----------------------|----------|-------------------------------------------------|
| `status:needs-review` | `fbca04` | Just triaged, waiting on a human decision       |
| `status:approved`     | `0e8a16` | Human said go — eligible for further processing |
| `status:discuss`      | `d93f0b` | Human wants to talk before anyone builds this   |
| `status:in-progress`  | `1d76db` | This issue was already dispatched               |

```
gh label create "status:needs-review" --color fbca04 --description "Just triaged, waiting on a human decision" --force
```

MCP: `mcp__github__label_write` (method: create) · REST:
`gh api repos/{owner}/{repo}/labels -X POST -f name=... -f color=... -f description=...`

(`--force` updates color/description if the label already exists rather than erroring — fine, since we own the
definition here.)

## Workflow

1. **Find untriaged issues**

   ```bash
   gh issue list --state open --json number,title,body,labels
   ```

   MCP: `mcp__github__list_issues` (state: open) · REST: `GET /repos/{owner}/{repo}/issues?state=open`

   Filter out anything that already carries a `status:*` label — that's the signal an issue has been through this skill
   before. No separate tracking file needed; GitHub's own labels are the state.

2. **Read the issue, and read the code it's about**

   ```bash
   gh issue view <n> --json body,comments
   ```

   MCP: `mcp__github__issue_read` (method: get / get_comments) · REST: `GET /repos/{owner}/{repo}/issues/{number}`

   Don't triage from the title alone. Open the relevant code before writing anything — the assessment later on is
   worthless if it's guessing.

3. **Apply labels**

    - One type label if a good fit (see [Common Labels](#common-labels) below) — skip it if nothing fits well; a wrong
      label is worse than no label.
    - `status:needs-review`.

   ```bash
   gh issue edit <n> --add-label "enhancement,status:needs-review"
   ```

   MCP: `mcp__github__issue_write` (method: update, labels) · REST:
   `gh api repos/{owner}/{repo}/issues/{number} -X PATCH -f 'labels[]=enhancement' -f 'labels[]=status:needs-review'`

4. **Assign it**

   ```bash
   gh issue edit <n> --add-assignee @me
   ```

   MCP: `mcp__github__issue_write` (method: update, assignees) · REST:
   `gh api repos/{owner}/{repo}/issues/{number} -X PATCH -f 'assignees[]=<username>'`

   `@me` resolves to whoever `gh` is authenticated as — MCP and REST need the actual username resolved first, there's no
   `@me` shorthand.

5. **Check for relationships — lightly**

   One quick search, not an investigation:

   ```bash
   gh search issues --repo {owner}/{repo} "<a couple of keywords from the title>"
   ```

   MCP: `mcp__github__search_issues` · REST: `GET /search/issues?q=<keywords>+repo:{owner}/{repo}+type:issue`

   Only mention something in the comment if it's a genuinely obvious overlap (near-duplicate, or clearly blocks/depends
   on another open issue). If nothing jumps out, say so in one word and move on.

6. **Post the triage comment**

   ```markdown
   **Triage**

   | Assessment | Related |
   |---|---|
   | <Easy win / Some complexity / Needs discussion / Showstopper> | <#NN if genuinely relevant, otherwise "Nothing obvious"> |

   <1-3 sentences — what it'll touch, what's non-obvious, any real blocker>

   Flip `status:needs-review` → `status:approved` when you're ready for this to be picked up, or → `status:discuss` if it needs a conversation first.
   ```

   Keep the notes sentence honest and specific — "touches the auth middleware's session handler, no schema change
   needed" is useful; "this looks doable" is not.

   ```bash
   gh issue comment <n> --body "$(cat <<'EOF'
   ...
   EOF
   )"
   ```

   MCP: `mcp__github__add_issue_comment` · REST:
   `gh api repos/{owner}/{repo}/issues/{number}/comments -X POST -f body=...`

7. **Report back**

   A short table to the user: issue number, title, assessment, labels applied. Nothing else needs to happen here — the
   next move is theirs, on GitHub, at whatever pace they want.

## Common Labels

Use these standard labels when applicable:

| Label              | Use For                       |
|--------------------|-------------------------------|
| `bug`              | Something isn't working       |
| `enhancement`      | New feature or improvement    |
| `documentation`    | Documentation updates         |
| `good first issue` | Good for newcomers            |
| `help wanted`      | Extra attention needed        |
| `question`         | Further information requested |
| `wontfix`          | Will not be addressed         |
| `duplicate`        | Already exists                |
| `high-priority`    | Urgent issues                 |

## Tips

- Confirm the repository context before running any `gh` command — they operate on whatever repo is active.
- If the issue lacks the detail needed to assess it, say so in the Notes rather than guessing — "unclear, needs more
  info" beats a confident wrong assessment.
- Only call out a related issue when it's genuinely relevant (step 5) — don't force a connection.

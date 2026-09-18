---
name: writing-readme
description: >
  Writes a clean, technical README.md for software projects. Use this skill whenever the user asks to
  create, write, generate, or improve a README — or when they say things like "document this project",
  "add a README", "write docs for this", or "what should my README say". Produces terse, technical
  documentation in a consistent style: bold project name, short description, and standard sections
  (Requirements, Installation, Configuration, Usage). Works for any language or project type by reading
  key source files to extract accurate information rather than making things up.
---

# Create README

## Goal

Produce a README.md that is accurate, terse, and useful to a developer setting up or integrating with
the project. No fluff, no marketing language, no emojis. Every sentence earns its place.

## Style

- Open with the project name in bold, followed immediately by a one- or two-sentence description of what
  it does and why it exists. No heading for this intro block.
- Use `##` for top-level sections, `###` for subsections.
- Keep prose short. Prefer a table or a code block over a paragraph when presenting structured data.
- Use fenced code blocks with a language tag for all command examples.
- Configuration tables: three columns — parameter name (YAML or flag style), environment variable or
  default, description. Add a fourth column for the default value if it is non-obvious.
- No trailing "happy path" sentences like "You're ready to go!" or "Enjoy your new service."
- No emojis.

## Required sections (in order)

1. **Intro block** — bold project name, then a short description.
2. **Requirements** — list of runtime dependencies with minimum versions where relevant.
3. **Installation** — numbered steps. Include build commands, config file locations, and any post-install
   wiring (symlinks, env vars, service registration).
4. **Configuration** — table of all config parameters. If the project uses both a config file and
   environment variables, show both.
5. **Usage** — how to actually run or call it. Include the most common invocation and any important flags.
   If it exposes an API or CLI, show a representative example.

Add other sections (Development, Testing, Contributing, License) only if the user requests them or the
project clearly warrants them.

## Workflow

### Step 1: Gather information efficiently

Do not read every file. Start with the files most likely to contain the information you need:

**Dependency and build declarations (read first):**

- Go: `go.mod`, `go.sum`
- Node: `package.json`
- Python: `pyproject.toml`, `setup.py`, `requirements.txt`
- Rust: `Cargo.toml`
- Ruby: `Gemfile`
- Other: any manifest or lockfile at the repo root

**Entry points and CLI args (read next):**

- `main.go`, `cmd/*/main.go`, `src/main.*`, `index.*`, `app.*`
- Anything that registers flags, defines a CLI, or starts an HTTP server

**Configuration schema (read next):**

- Config structs, default value declarations, `config.go`, `settings.py`, `config.ts`, etc.
- Example config files: `config.example.*`, `*.example.yaml`, `.env.example`

**Ask the user if unsure.** Before reading large numbers of files, say something like: "I found X, Y, Z.
Are there other files I should look at — for instance, where config options are defined or where the HTTP
routes live?" One focused question is better than reading 20 files speculatively.

### Step 2: Fill gaps

If information is missing after reading the key files, check:

- Existing comments or doc strings near the entry point
- Test files for usage examples
- CI config (`.github/workflows`, `Makefile`, `Dockerfile`) for build and run commands

If something genuinely cannot be determined from the code, use a clear placeholder:
`<TODO: describe X>` so the user knows what to fill in.

### Step 3: Draft and present

Write the full README.md. Then ask the user: "Does this look right? Anything missing or incorrect?"
Apply corrections and re-present if there are substantive changes.

When done, offer to write the file: "Should I write this to `README.md`?" Wait for confirmation before
overwriting any existing file.

## Configuration table format

Use this column order: YAML/flag | Env var | Default | Description

Example:

| Parameter       | Environment Variable | Default     | Description                          |
|:----------------|:---------------------|:------------|:-------------------------------------|
| `server.port`   | `SERVER_PORT`        | `8080`      | Port to listen on.                   |
| `logLevel`      | `LOG_LEVEL`          | `info`      | Log level: debug, info, warn, error. |

If the project uses only one of YAML or env vars, drop the other column.

## Tone reference

The target is a README that reads like this excerpt:

> **task-queue** is a lightweight Go service that distributes background jobs across worker processes
> and tracks their completion status.
>
> It exposes a small HTTP API for enqueueing jobs and polling their state, suitable for embedding in an
> existing backend.

Notice: one bold project name, two short sentences, no hype, no "welcome to", no first-person.

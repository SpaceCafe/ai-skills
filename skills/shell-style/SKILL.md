---
name: shell-style
description: "Use when writing, reviewing, linting, or refactoring bash or POSIX sh scripts, including Docker entrypoints and build wrappers."
metadata: 
  node_type: memory
  modified: 2026-09-19T08:21:00.205Z
  originSessionId: dba9dd83-4089-4d2e-86c1-ce5f4b33578c
---

# Shell Style

## Overview

A style guide for bash and POSIX sh scripts. Check the shebang first; it decides the dialect:

- `#!/bin/bash`: the full bash feature set is available. **REQUIRED:** read `bash.md` in this skill.
- `#!/bin/sh`: must run under BusyBox `ash` or `dash`. **REQUIRED:** read `posix-sh.md` in this skill.

Never use bash-only syntax in a `#!/bin/sh` file. Never force a `#!/bin/bash` script to stay POSIX-compatible.

## Shared conventions (both dialects)

| Rule                                                                                                                          | Example                                 |
|-------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------|
| Header: shebang → `## ---` rule → title → blank `##` → `@author`/`@date` → `## ---` rule → blank line → `set -eu[o pipefail]` | see template below                      |
| `@date` in ISO 8601 (`yyyy-mm-dd`)                                                                                            | `## @date       2026-05-27`             |
| Section banners: same `## ---` rule above/below a Title Case heading for each major logical block                             | `## Command-Line Argument Parsing`      |
| snake_case for every function and variable name                                                                               | `get_targets`, `load_secret`            |
| Every variable expansion double-quoted                                                                                        | `"$target"`, `"$file_path"`             |
| `--` before any variable/user-controlled argument that could start with `-`                                                   | `rm -rf -- "$path"`, `cat -- "$file"`   |
| Validate required inputs at the top of the function/script, before doing work                                                 | `assert_env`, `${1:?missing argument}`  |
| Group related `readonly` declarations into one statement, after the values are final                                          | `readonly VAR1 VAR2 VAR3`               |
| `: "${VAR:=default}"` for defaultable variables                                                                               | `: "${SKIP_SIGNING:=0}"`                |
| `if` block instead of `test && cmd` when the test can be false (under `set -e`, a false last command fails the function)      | `if [ -n "$x" ]; then ...; fi`          |
| Logging: `printf` to stderr or `gum`, never `echo` (see "Logging and section headers" below)                                  | `printf "[sign] INFO: ...\n" >&2`       |
| Comments explain WHY, never WHAT                                                                                              | see Common Mistakes below               |
| Prefer long-form CLI flags over short ones                                                                                    | `--verbose` not `-v`                    |

Header template:

```sh
#!/bin/bash
## -----------------------------------------------------------------------------
## <One-line description of what this script does>
##
## @author     <Name> <email>
## @date       <yyyy-mm-dd>
## -----------------------------------------------------------------------------

set -euo pipefail
```

## Logging and section headers

Pick the logging tool by the first matching condition:

1. The script is `#!/bin/sh` or runs inside a container: use `printf` to stderr. `gum` is not installed there.
2. The script or its project already calls `gum`: use `gum`.
3. Otherwise, ask the user whether to add `gum` as a dependency.

### printf

A bracketed tag, a level, then the message, always to stderr:

```sh
printf "[sign] INFO: signing %s\n" "$image_ref" >&2
```

### gum

- Section banner before a major step:
  ```sh
  gum style --border rounded --bold --padding "0 2" "Signing image"
  ```
- Structured log line: one `--structured` label, then `key value` pairs for every variable worth showing:
  ```sh
  gum log --level debug --structured "Current settings:" image_ref "$image_ref"
  ```
- Levels: `debug`, `info`, `warn`, `error`. Gate `debug` behind a `--debug` flag that exports
  `GUM_LOG_LEVEL="debug"` before any `gum log` call, so normal runs stay quiet.

## Review checklist

When reviewing or refactoring a shell script against this style, flag:

- Bash syntax (`[[ ]]`, `local`, arrays, `pipefail`, `+=`) in a `#!/bin/sh` file.
- An unquoted variable expansion outside arithmetic or an intentional word-split loop. Check this by
  hand: the project's `.shellcheckrc` disables SC2086, so shellcheck does not report it.
- A bash script that builds a command line in a string instead of an array.
- A command (`rm`, `cat`, `readlink`, or any external binary) called with a variable argument and no
  `--` separator.
- A function that does work before validating its required arguments/env.
- `echo` anywhere a value is printed or logged.
- `test && cmd` as the last command of a function or script under `set -e`.
- A missing or malformed header/section banner.
- A low-level POSIX sh helper that calls `exit` instead of `return` (see `posix-sh.md`).

Run `shellcheck <script>` before finishing a review.

## Common mistakes

- **Comments that restate the code.** `# increment counter` above `i=$((i + 1))` adds nothing. Write a
  comment only when it explains a non-obvious reason: a workaround, a security rationale, a portability
  quirk, or an invariant that the code does not show.
- **Mixing dialect features.** A `#!/bin/sh` script can work locally because `/bin/sh` is bash there,
  then break under `dash`/`ash` in production. Test POSIX sh scripts against a real POSIX shell
  (`busybox sh script.sh` or `dash script.sh`), not just bash.

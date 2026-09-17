# Doxygen Comments — Bash / Shell

Bash has no block comment syntax. Doxygen processes shell scripts using
`#`-prefixed comment lines. The convention is to use `##` for documentation
lines (double-hash) so they stand out from regular inline comments.

The first sentence of a comment block is the brief description — no `@brief`
tag needed.

Doxygen configuration needed:
```
FILE_PATTERNS = *.sh *.bash
INPUT_FILTER  = "sed 's/^##/#/'"   # strips one # so Doxygen sees normal comments
```

---

## File header

```bash
## ---------------------------------------------------------------------------
## Deploys the application to the configured environment.
##
## @author     Jane Doe <jane.doe@example.org>
## @date       2024-01-15
## ---------------------------------------------------------------------------
```

*(Shell scripts have no closing delimiter — the header ends with a `## ---`
dash line to mirror the visual style of block-comment languages.)*

---

## Function

```bash
## Validates that a required environment variable is set and non-empty.
#
# @param  $1  Name of the environment variable to check.
# @return 0 if the variable is set and non-empty; 1 otherwise.
#
# @note   Prints an error message to stderr on failure.
#
# @example
# @code
#   require_env "DATABASE_URL" || exit 1
# @endcode
validate_env_var() {
    local var_name="$1"
    if [[ -z "${!var_name}" ]]; then
        echo "ERROR: Required variable '$var_name' is not set." >&2
        return 1
    fi
    return 0
}
```

---

## Function with multiple parameters

```bash
## Copies files matching a glob pattern to a destination directory.
#
# @param  $1  Source glob pattern (e.g. "build/*.js").
# @param  $2  Destination directory path; created if it does not exist.
# @param  $3  (optional) File permission mode in octal (default: 644).
# @return 0 on success; non-zero cp/chmod exit code on failure.
#
# @warning Existing files in the destination are overwritten without prompt.
copy_artifacts() {
    local pattern="$1"
    local dest="$2"
    local mode="${3:-644}"
    ...
}
```

---

## Constants / global variables

```bash
## Maximum seconds to wait for the deployment health check.
readonly DEPLOY_TIMEOUT=120

## Logging verbosity: 0=silent, 1=error, 2=info, 3=debug.
LOG_LEVEL="${LOG_LEVEL:-2}"
```

---

## Script-level section dividers (optional)

For longer scripts, use a comment divider to group sections:

```bash
## ---------------------------------------------------------------------------
## Initialisation — parse args and validate environment.
## -------------------------------------------------------------------------
```

---

## Bash-specific notes

- Positional parameters (`$1`, `$2`, …): always document them with `@param $N`.
- If a function relies on named variables from a parent scope (dynamic scoping
  via `local -n` or simple name references), document this with `@note`.
- Return values: Bash functions return exit codes (0 = success). Document the
  meaning of non-zero codes.
- If a function writes to stdout (i.e. is meant to be captured via `$()`),
  state this in `@return` or `@note`.
- `@throws` is not idiomatic for shell; use `@return non-zero exit code on
  failure` or describe error conditions in `@note` / `@warning`.

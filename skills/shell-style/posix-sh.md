# POSIX sh conventions

Applies to scripts shebanged `#!/bin/sh` that must run under a minimal POSIX shell: BusyBox `ash`
(common in Alpine-based containers), `dash` (Debian's default `/bin/sh`), or any environment where bash
isn't guaranteed. No `local`, no `[[ ]]`, no arrays, no `pipefail`, no `+=`.

## Strict mode

```sh
set -eu
```

No `pipefail`. POSIX.1-2024 added it and BusyBox `ash` supports it, but older `dash` releases do not.
Check each pipeline's exit status explicitly where it matters.

## No `local`: underscore-prefixed pseudo-locals

POSIX sh has no reliable variable scoping. Prefix scratch variables with `_` so a reader knows they're
function-internal, not part of the script's real state:

```sh
uri_encode() {
    _result=""
    _len="${#1}"
    _i=1
    while [ "$_i" -le "$_len" ]; do
        ...
    done
    printf '%s' "$_result"
}
```

## Underscore-prefixed "private" functions

A function only meant to be called by other functions in the same file gets a leading underscore; the
public API doesn't:

```sh
_check_env_name() { ... }   # internal
_get_env_value() { ... }    # internal
load_env() { ... }          # public, calls the above
```

## Conditionals: `[ ]` and `case`, never `[[ ]]` or `=~`

Pattern and format validation goes through `case`, since POSIX sh has no regex test operator:

```sh
case "$1" in
    *[!A-Z0-9_-]* | '')
        printf "[config] ERROR: invalid env var name: %s\n" "$1" >&2
        return 1
        ;;
esac
```

## `return` in helpers, `exit` in wrappers

A low-level, reusable function returns non-zero and lets the caller decide what to do next. Only a
`must_*` / `assert_*` wrapper, or top-level script logic, calls `exit`:

```sh
load_secret() {
    ...
    return 1   # caller decides
}

must_load_secret() {
    load_secret "$1" || exit 1   # this one is allowed to exit
}
```

## `printf`, never `echo`

`echo` flag and backslash handling isn't portable across `/bin/sh` implementations. Always
`printf '%s'` (no trailing-newline mangling) or `printf '%s\n'`:

```sh
printf "[secure-config] INFO: %s ready (mode=700, owner=%s:%s)\n" "$config_dir" "$uid" "$gid"
```

## Error/log message format

`[context-tag] LEVEL: message`, always to stderr:

```sh
printf "[config] ERROR: failed to read secret (%s)\n" "$1" >&2
```

Pick a small, consistent set of tags (one per subsystem, e.g. `[config]`, `[setup]`, `[start]`) and
levels (`ERROR`, `INFO`, `WARN`), and reuse them everywhere rather than inventing new wording per call site.

## IFS discipline

Save and restore `IFS` around any loop that needs non-default word-splitting; never leave it changed
after the loop. An unquoted expansion also expands globs, so disable globbing with `set -f` for the
same span:

```sh
_old_ifs="$IFS"
IFS=:
set -f
for _dir in $PATH; do
    ...
done
set +f
IFS="$_old_ifs"
```

Read loops over command output: always `IFS= read -r`, never a bare `read`:

```sh
... | while IFS= read -r _item; do
    ...
done
```

## Path safety

Canonicalize with `readlink -f` before trusting any path built from user or env input, then re-verify
the result is still under the expected root. A symlink inside an otherwise-safe directory can point
outward:

```sh
_real="$(readlink -f -- "$_path")" || _real=""
case "$_real" in
    /expected/root/*) ;;
    *)
        printf "[config] ERROR: path escapes expected root (got: %s)\n" "$_path" >&2
        exit 1
        ;;
esac
```

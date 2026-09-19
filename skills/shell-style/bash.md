# Bash conventions

Applies to scripts shebanged `#!/bin/bash`: anything guaranteed to run where bash is present (a dev
machine, CI, a full-featured base image), where the full bash feature set is safe to use.

## Strict mode

```sh
set -euo pipefail
```

`pipefail` is bash-only. POSIX sh scripts can't use it (see `posix-sh.md`).

## Function-local variables

Always `local`. Declare a required positional argument with the `${1:?message}` idiom, so a missing
argument fails with a clear message instead of an unbound-variable error:

```sh
sign() {
    local image_ref="${1:?missing image reference}"
    ...
}
```

For a function with several locals, declare them together at the top, even before they're assigned, so
a reader sees at a glance what the function touches:

```sh
main() {
    local context
    local image_name
    local image_ref
    ...
}
```

## Conditionals

`[[ ... ]]`, never `[ ... ]`. It avoids word-splitting and glob surprises, and supports `==` pattern
matching directly. Use an `if` block, not `[[ ... ]] && cmd`: under `set -e`, a false test as the last
command of a function makes the function fail and stops the script.

```sh
if [[ "$skip_cleanup" == "1" ]]; then
    ...
fi
```

## Arrays for command lines

Build a command line in an array, never in a string. A string forces an unquoted expansion later, which
breaks on any value containing spaces or globs:

```sh
local -a args=(--file docker-bake.hcl)
if [[ -n "$stage" ]]; then
    args+=(--set "$target.target=$stage")
fi
docker buildx bake "${args[@]}" "$target"
```

## CLI argument parsing

A `case` loop over `$@`. Each option handles both `--flag value` and `--flag=value`, pairing the long
and short forms in the same arm. `--` ends option parsing; an unrecognized `-*` is a hard error:

```sh
case $1 in
    --target | -t)
        target="$2"
        shift 2
        ;;
    --target=* | -t=*)
        target="${1#*=}"
        shift
        ;;
    --)
        shift
        break
        ;;
    -*)
        printf "[args] ERROR: unknown option: %s\n" "$1" >&2
        exit 1
        ;;
    *)
        target="$1"
        shift
        break
        ;;
esac
```

## Cleanup

`trap <function> EXIT` for anything that must run regardless of how the script exits (temp dirs,
background jobs):

```sh
trap cleanup EXIT
```

## Logging and section headers

See "Logging and section headers" in `SKILL.md`. The gum and `printf` rules apply to both dialects.

## Readonly grouping

Compute values first, then freeze them in one statement:

```sh
readonly SKIP_SIGNING SKIP_SLIMIFY SKIP_CLEANUP TARGET STAGE
```

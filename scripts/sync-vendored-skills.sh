#!/usr/bin/env bash
## -----------------------------------------------------------------------------
## Sync vendored skills from upstream repositories using git subtree
##
## Reads entries from scripts/vendored-skills.json, records the resolved commit
## and timestamp of each sync in scripts/vendored-skills.lock.json, and
## regenerates ATTRIBUTION.md from the lock file after every run. A successful
## sync leaves both files modified but uncommitted; commit them afterwards.
##
## Requires: git, jq, gum
##
## @author     Lars Thoms <lars@thoms.io>
## @date       2026-09-19
## -----------------------------------------------------------------------------

set -euo pipefail


## -----------------------------------------------------------------------------
## Constants
## -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/vendored-skills.json"
LOCK_FILE="${SCRIPT_DIR}/vendored-skills.lock.json"
ATTRIBUTION_FILE="${REPO_ROOT}/ATTRIBUTION.md"
SPLIT_BRANCH_PREFIX="subtree-split"
readonly SCRIPT_DIR REPO_ROOT CONFIG_FILE LOCK_FILE ATTRIBUTION_FILE SPLIT_BRANCH_PREFIX

# gum shows every level by default, so normal runs must opt out of debug output.
: "${GUM_LOG_LEVEL:=info}"
export GUM_LOG_LEVEL

# Set by sync_entry and read by cleanup_worktree. They are deliberately global:
# under 'set -eu', bash unwinds a function's local scope before running an EXIT
# trap fired by a failing command inside it, so a trap that references a local
# dies with "unbound variable" before its cleanup runs.
sync_tmp_parent=""
sync_worktree=""


## -----------------------------------------------------------------------------
## Helpers
## -----------------------------------------------------------------------------

usage() {
    cat <<'EOF'
Usage:
  scripts/sync-vendored-skills.sh [--debug]                     # sync all entries
  scripts/sync-vendored-skills.sh [--debug] <name>              # sync only the named entry
  scripts/sync-vendored-skills.sh [--debug] --list              # list configured entries
  scripts/sync-vendored-skills.sh [--debug] --attribution-only  # regenerate ATTRIBUTION.md only
EOF
}

die() {
    local message="${1:?missing error message}"

    gum log --level error "${message}"
    exit 1
}

usage_error() {
    local message="${1:?missing error message}"

    gum log --level error "${message}"
    usage >&2
    exit 2
}

require_commands() {
    local cmd
    local -a missing=()

    for cmd in "$@"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            missing+=("${cmd}")
        fi
    done

    # printf instead of gum: gum itself may be one of the missing commands.
    if (( ${#missing[@]} > 0 )); then
        printf "[sync] ERROR: required but not installed: %s\n" "${missing[*]}" >&2
        exit 1
    fi
}

# Rewrite LOCK_FILE through a temp file, so a failing jq never truncates it.
# All arguments go to jq; the lock file is appended as its input.
rewrite_lock_file() {
    local tmp_lock

    tmp_lock="$(mktemp "${LOCK_FILE}.XXXXXX")"
    if ! jq "$@" "${LOCK_FILE}" >"${tmp_lock}"; then
        rm -f -- "${tmp_lock}"
        return 1
    fi
    mv -- "${tmp_lock}" "${LOCK_FILE}"
}

cleanup_worktree() {
    if [[ -n "${sync_worktree}" ]]; then
        git worktree remove --force -- "${sync_worktree}" &>/dev/null || true
    fi
    if [[ -n "${sync_tmp_parent}" ]]; then
        rm -rf -- "${sync_tmp_parent}"
    fi
    sync_worktree=""
    sync_tmp_parent=""
}


## -----------------------------------------------------------------------------
## Config Validation
## -----------------------------------------------------------------------------

validate_config() {
    local invalid_entries
    local duplicate_names

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        die "Config file not found: ${CONFIG_FILE}"
    fi

    if ! jq empty "${CONFIG_FILE}" 2>/dev/null; then
        die "Config file is not valid JSON: ${CONFIG_FILE}"
    fi

    if ! jq --exit-status '.skills? and (.skills | type == "array")' "${CONFIG_FILE}" >/dev/null 2>&1; then
        die "Config file must have a top-level \"skills\" array: ${CONFIG_FILE}"
    fi

    invalid_entries="$(jq --raw-output '
        [.skills[] | select(
            [.name, .repoUrl, .ref, .upstreamPath, .localPath] | any(. == null or . == "")
        ) | (.name // "<unnamed>")] | join(", ")
    ' "${CONFIG_FILE}")"
    if [[ -n "${invalid_entries}" ]]; then
        die "Config entries missing a required field (name/repoUrl/ref/upstreamPath/localPath): ${invalid_entries}"
    fi

    duplicate_names="$(jq --raw-output '
        [.skills[].name] | group_by(.) | map(select(length > 1) | .[0]) | join(", ")
    ' "${CONFIG_FILE}")"
    if [[ -n "${duplicate_names}" ]]; then
        die "Duplicate skill names in config: ${duplicate_names}"
    fi
}


## -----------------------------------------------------------------------------
## Lock File and Attribution
## -----------------------------------------------------------------------------

update_lock_entry() {
    local name="${1:?missing skill name}"
    local repo_url="${2:?missing repo URL}"
    local ref="${3:?missing ref}"
    local upstream_path="${4:?missing upstream path}"
    local local_path="${5:?missing local path}"
    local commit="${6:?missing commit}"
    local synced_at

    # Short flag: BSD date (macOS) has no --utc.
    synced_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    # shellcheck disable=SC2016 # $name etc. are jq variables, not shell ones.
    rewrite_lock_file \
        --arg name "${name}" \
        --arg repo_url "${repo_url}" \
        --arg ref "${ref}" \
        --arg upstream_path "${upstream_path}" \
        --arg local_path "${local_path}" \
        --arg commit "${commit}" \
        --arg synced_at "${synced_at}" \
        '.skills[$name] = {
            "repoUrl": $repo_url,
            "ref": $ref,
            "upstreamPath": $upstream_path,
            "localPath": $local_path,
            "commit": $commit,
            "syncedAt": $synced_at
        }'
}

prune_stale_lock_entries() {
    # shellcheck disable=SC2016 # $config etc. are jq variables, not shell ones.
    rewrite_lock_file --slurpfile config "${CONFIG_FILE}" '
        ($config[0].skills | map(.name)) as $names
        | .skills |= with_entries(select(.key as $k | $names | index($k)))
    '
}

generate_attribution() {
    {
        cat <<'EOF'
# Attribution

This file is auto-generated by `scripts/sync-vendored-skills.sh`.
Do not edit by hand. The next sync overwrites any manual changes.

The following skills are vendored from upstream repositories using
`git subtree`, which preserves the original commit history and
authorship (visible via `git log --follow <localPath>`).

| Skill | Local Path | Source | Ref | Commit | Last Synced |
|---|---|---|---|---|---|
EOF

        jq --raw-output '
            def esc: gsub("\\|"; "\\|");
            .skills
            | to_entries
            | sort_by(.key)
            | .[]
            | "| \(.key|esc) | `\(.value.localPath|esc)` | [\(.value.repoUrl|esc)](\(.value.repoUrl|esc)) (`\(.value.upstreamPath|esc)`) | \(.value.ref|esc) | `\(.value.commit[0:12])` | \(.value.syncedAt) |"
        ' "${LOCK_FILE}"

        cat <<'EOF'

> Please respect the license of each upstream repository when using
> or redistributing these skills.
EOF
    } >"${ATTRIBUTION_FILE}"

    gum log --level info --structured "Regenerated attribution file" path "${ATTRIBUTION_FILE}"
}


## -----------------------------------------------------------------------------
## Sync
## -----------------------------------------------------------------------------

sync_entry() {
    local name="${1:?missing skill name}"
    local repo_url="${2:?missing repo URL}"
    local ref="${3:?missing ref}"
    local upstream_path="${4:?missing upstream path}"
    local local_path="${5:?missing local path}"
    local split_branch="${SPLIT_BRANCH_PREFIX}-${name}"
    local resolved_commit

    gum style --border rounded --bold --padding "0 2" "Syncing ${name}"
    gum log --level debug --structured "Entry settings:" \
        repo_url "${repo_url}" \
        ref "${ref}" \
        upstream_path "${upstream_path}" \
        local_path "${local_path}" \
        split_branch "${split_branch}"

    # Fetch directly from the URL into FETCH_HEAD, rather than through a
    # persistent remote, so a changed repoUrl is always picked up and 'git
    # remote -v' doesn't accumulate one entry per vendored skill. This also
    # means 'ref' can be a branch, a tag, or (server permitting) a commit SHA.
    git fetch --no-tags -- "${repo_url}" "${ref}"

    if ! resolved_commit="$(git rev-parse --verify --quiet 'FETCH_HEAD^{commit}')"; then
        die "Failed to resolve ref '${ref}' from ${repo_url}."
    fi
    gum log --level debug --structured "Resolved ref:" commit "${resolved_commit}"

    if [[ -z "$(git ls-tree -r --name-only "${resolved_commit}" -- "${upstream_path}")" ]]; then
        die "Path '${upstream_path}' not found in ${repo_url} at ref '${ref}' (commit ${resolved_commit:0:12})."
    fi

    # A split branch left over from an aborted run would make 'subtree split'
    # append to stale history instead of rebuilding it.
    git branch --delete --force -- "${split_branch}" &>/dev/null || true

    # 'git subtree split' checks for the prefix on disk (relative to the
    # working tree), not just in the given commit's tree. A throwaway worktree
    # checked out at resolved_commit has the prefix present, so the split runs
    # there. The main working tree and index stay untouched, which keeps a
    # mid-sync failure from leaving anything staged.
    sync_tmp_parent="$(mktemp -d)"
    sync_worktree="${sync_tmp_parent}/wt"
    trap cleanup_worktree EXIT

    git worktree add --detach --quiet -- "${sync_worktree}" "${resolved_commit}"

    (
        cd -- "${sync_worktree}"
        git subtree split \
            --prefix="${upstream_path}" \
            --branch="${split_branch}" \
            "${resolved_commit}"
    )

    cleanup_worktree
    trap - EXIT

    if jq --exit-status --arg name "${name}" '.skills[$name]' "${LOCK_FILE}" >/dev/null; then
        git subtree merge --prefix="${local_path}" --message="Update vendored skill: ${name}" "${split_branch}"
    else
        git subtree add --prefix="${local_path}" --message="Add vendored skill: ${name}" "${split_branch}"
    fi

    git branch --delete --force -- "${split_branch}"

    update_lock_entry "${name}" "${repo_url}" "${ref}" "${upstream_path}" "${local_path}" "${resolved_commit}"

    gum log --level info --structured "Synced" \
        skill "${name}" \
        path "${local_path}" \
        commit "${resolved_commit:0:12}"
}


## -----------------------------------------------------------------------------
## Command-Line Argument Parsing
## -----------------------------------------------------------------------------

MODE="sync"
FILTER_NAME=""

while (( $# > 0 )); do
    case $1 in
        --help | -h)
            usage
            exit 0
            ;;
        --debug)
            GUM_LOG_LEVEL="debug"
            shift
            ;;
        --list)
            MODE="list"
            shift
            ;;
        --attribution-only)
            MODE="attribution"
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            usage_error "Unknown option: $1"
            ;;
        *)
            break
            ;;
    esac
done

if (( $# > 1 )); then
    usage_error "Too many arguments."
fi
FILTER_NAME="${1:-}"

if [[ -n "${FILTER_NAME}" && "${MODE}" != "sync" ]]; then
    usage_error "A skill name cannot be combined with --list or --attribution-only."
fi

readonly MODE FILTER_NAME


## -----------------------------------------------------------------------------
## Main
## -----------------------------------------------------------------------------

require_commands git jq gum

cd -- "${REPO_ROOT}"

gum log --level debug --structured "Current settings:" \
    mode "${MODE}" \
    filter_name "${FILTER_NAME}" \
    config_file "${CONFIG_FILE}" \
    lock_file "${LOCK_FILE}"

validate_config

if [[ "${MODE}" == "list" ]]; then
    printf "Configured vendored skills:\n"
    jq --raw-output '.skills[] | "  - \(.name): \(.repoUrl) (\(.ref)) [\(.upstreamPath) -> \(.localPath)]"' "${CONFIG_FILE}"
    exit 0
fi

if [[ -n "${FILTER_NAME}" ]] &&
    ! jq --exit-status --arg n "${FILTER_NAME}" 'any(.skills[]?; .name == $n)' "${CONFIG_FILE}" >/dev/null; then
    die "No configured skill named '${FILTER_NAME}'. Use --list to see available entries."
fi

# 'git subtree add/merge' is unsafe with uncommitted changes present.
if [[ "${MODE}" == "sync" && -n "$(git status --porcelain)" ]]; then
    gum log --level error "Working tree is not clean. Commit, stash, or discard changes before running this script."
    git status --short >&2
    exit 1
fi

if [[ ! -f "${LOCK_FILE}" ]]; then
    printf '{"skills": {}}\n' >"${LOCK_FILE}"
fi

if [[ "${MODE}" == "attribution" ]]; then
    generate_attribution
    exit 0
fi

while IFS=$'\t' read -r name repo_url ref upstream_path local_path; do
    if [[ -n "${FILTER_NAME}" && "${FILTER_NAME}" != "${name}" ]]; then
        continue
    fi
    sync_entry "${name}" "${repo_url}" "${ref}" "${upstream_path}" "${local_path}"
done < <(jq --raw-output '.skills[] | [.name, .repoUrl, .ref, .upstreamPath, .localPath] | @tsv' "${CONFIG_FILE}")

# A filtered run only sees one entry, so it cannot tell which lock entries are stale.
if [[ -z "${FILTER_NAME}" ]]; then
    prune_stale_lock_entries
fi

generate_attribution

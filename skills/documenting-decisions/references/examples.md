# Comment syntax and examples by format

## Syntax by file type

| Format                        | Single-line    | Multi-line         |
|-------------------------------|----------------|--------------------|
| nginx, shell, Dockerfile      | `# …`          | `# …` (multiline)  |
| PHP ini                       | `; …`          | `; …` (multiline)  |
| TOML, YAML                    | `# …`          | `# …` (multiline)  |
| PHP, JavaScript, TypeScript   | `// …`         | `/* … */`          |
| Python                        | `# …`          | `# …` (multiline)  |
| Go                            | `// …`         | `/* … */`          |

---

## Inline code formatting within comments

Wrap variable names, file paths, shell values, config keys, directives, and any literal token
in backticks inside comment text. Plain prose words stay unformatted.

```shell
# `HISTFILE=/dev/null` rather than unsetting it: some shells fall back to
# `~/.bash_history` when `HISTFILE` is unset. `HISTSIZE=1000` preserves
# in-session history while preventing it from being written to disk.
```

---

## nginx

```nginx
worker_processes auto;
tcp_nopush       on;

# Revalidate every second. This is aggressive but safe when deploys update files atomically.
open_file_cache_valid 1s;

# Short to free worker connections quickly behind a load balancer.
keepalive_timeout 30s;

# Required when serving both gzip and brotli so proxies cache separate variants.
gzip_vary on;

# Each connection needs 2 FDs (client + upstream) and the cache adds more.
worker_rlimit_nofile 16384;
```

Block comment, for a decision with a "we tried X and it broke Y" history:

```nginx
# open_file_cache_errors is off even though errors are cached by default.
# Moodle's plugin loader probes for optional include paths that may not exist.
# Caching those 404s causes spurious failures after a plugin is installed
# without reloading nginx.
open_file_cache_errors off;
```

Self-evident directives need no comment at all:

```nginx
server_tokens off;
sendfile      on;
tcp_nopush    on;
access_log    off;
multi_accept  on;
```

---

## PHP ini

```ini
; Moodle backup and bulk-grade operations allocate large result sets in memory (default: 128M).
memory_limit = 512M
```

Block comment, for a deliberate deviation from a hardening baseline:

```ini
; Moodle calls external binaries (gs, pdftoppm, php, du) via exec().
; exec() is re-enabled here, overriding the security baseline in 80-security.ini.
; All other functions from that baseline remain disabled.
disable_functions = passthru,shell_exec,system,proc_open,...
```

---

## PHP

```php
// array_splice() instead of unset() + array_values(): preserves numeric keys being reset,
// which the downstream serialiser depends on.
array_splice($items, $index, 1);
```

When the why needs more than 3-4 lines, point to an ADR instead:

```php
// Session token storage was redesigned for compliance (see docs/adr/adr-0001-session-tokens.md).
```

---

## Python

```python
# hashlib.md5 used intentionally for a cache key, not cryptographic security.
# It is fast and collision-resistant enough for this purpose.
cache_key = hashlib.md5(content).hexdigest()
```

---

## TypeScript / JavaScript

Block comment, for a workaround or surprising behaviour:

```typescript
/*
 * We sort before deduplication rather than after. Sorting a deduplicated list
 * would be cheaper, but the comparator relies on stable original ordering to
 * break ties. Deduplication destroys that information.
 */
const result = deduplicate(items.sort(comparator));
```

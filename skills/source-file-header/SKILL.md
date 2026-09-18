---
name: source-file-header
description: Style guide for file-level header blocks. Apply when creating any new file (shell, Dockerfile, PHP, INI, template, etc.) to generate a consistent doxygen-style header with separator lines, title, @author, and @date tags.
---

# File header style

Every file begins with a header block consisting of:

1. An opening separator line (80 characters total)
2. A title line
3. An optional blank comment line followed by bullet notes or links
4. A blank comment line
5. `@author` tag (aligned to column 17 after the comment prefix)
6. `@date` tag in `YYYY-MM-DD` format (use today's date)
7. A closing separator line (identical to the opening)

The separator line is exactly 80 characters: the comment prefix, then dashes to fill the rest.

---

## Comment prefix by file type

| File type                        | Prefix | Separator (80 chars total) |
|----------------------------------|--------|----------------------------|
| Shell (`.sh`), Dockerfile        | `##`   | `##` + 77 dashes           |
| PHP ini (`.ini`, `.conf`)        | `;;`   | `;;` + 78 dashes           |
| PHP (`.php`), templates (`.tpl`) | `//`   | `//` + 78 dashes           |
| Python (`.py`)                   | `##`   | `##` + 77 dashes           |
| JavaScript/TypeScript            | `//`   | `//` + 78 dashes           |

---

## Tag alignment

Tags are indented with enough spaces so the value starts at column 17 (counting from after the comment prefix + one
space):

```text
## @author     Your Name <you@example.com>
## @date       2026-04-07
```

`@author` (7 chars) + 5 spaces = 12, then value at column 13 relative to prefix.
`@date` (5 chars) + 7 spaces = 12, then value at column 13 relative to prefix.

The effect is that both values are left-aligned with each other.

---

## Examples

**Shell script or Dockerfile:**

```sh
## -----------------------------------------------------------------------------
## Docker entrypoint
##
## @author     Your Name <you@example.com>
## @date       2026-04-20
## -----------------------------------------------------------------------------
```

**Dockerfile with no extra notes:**

```dockerfile
## -----------------------------------------------------------------------------
## Application Dockerfile
##
## @author     Your Name <you@example.com>
## @date       2026-04-20
## -----------------------------------------------------------------------------
```

**PHP ini:**

```ini
;; -----------------------------------------------------------------------------
;; PHP configuration file
;;
;; @author     Your Name <you@example.com>
;; @date       2026-04-20
;; -----------------------------------------------------------------------------
```

**PHP / template with reference notes:**

```php
// -----------------------------------------------------------------------------
// Application configuration file
// - See docs/configuration.md for the full list of options
// - Related: docs/session-handling.md
//
// @author     Your Name <you@example.com>
// @date       2026-04-20
// -----------------------------------------------------------------------------
```

**Shell script with description:**

```sh
## -----------------------------------------------------------------------------
## CLI wrapper script
##
## Forwards calls to the underlying binary while injecting default flags.
## Install via symlink (`ln -sf wrapper.sh mytool`).
##
## @author     Your Name <you@example.com>
## @date       2026-04-20
## -----------------------------------------------------------------------------
```

**Python:**

```python
## -----------------------------------------------------------------------------
## Database migration helper
##
## @author     Your Name <you@example.com>
## @date       2026-04-20
## -----------------------------------------------------------------------------
```

**JavaScript / TypeScript:**

```ts
// -----------------------------------------------------------------------------
// API client
//
// @author     Your Name <you@example.com>
// @date       2026-04-20
// -----------------------------------------------------------------------------
```

---

## Rules

- Always use today's date for `@date` — do not copy an existing date from another file.
- The separator line must be exactly 80 characters. Count carefully; do not eyeball it.
- If the file has a shebang (`#!/…`), the header starts on line 2 (blank line or directly
  after the shebang as appropriate for the file type).
- Do not add a trailing blank line inside the header block.
- Notes and links go between the title and the blank comment line before the tags.
- Use the author name and email from `git config user.name` and `git config user.email`.
  Fall back to `Your Name <you@example.com>` if git config is unavailable.

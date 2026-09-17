---
name: writing-doxygen-comments
description: >
  Use when adding, writing, improving, or replacing documentation comments,
  docblocks, or Doxygen annotations in source code — including requests
  phrased as "add comments", "document this function", "document my code",
  "add docstrings", "write docs for this", or "comment this file".
  Covers Python, TypeScript, JavaScript, Bash/Shell, PHP, C, C++, Java,
  Go, and Rust.
---

# Doxygen-Style Commenting Skill

This skill adds structured Doxygen-style documentation comments to source
code. The goal is to document **what** code does — its purpose, inputs,
outputs, side effects, and edge cases — not *how* it works internally.

---

## Workflow

### Step 1 — Assess existing comments

Before writing anything:

- **No useful comments exist**: add Doxygen comments directly without asking.
  "Useful" means comments that convey intent, behaviour, or context beyond what
  the code itself makes obvious.
- **Useful comments exist**: ask the user before replacing them.
  Say something like: *"This code already has comments. Should I replace them
  with Doxygen-style ones? I'll use the existing content as context."*
  If the user says yes, preserve the meaning of the old comments — fold their
  information into the new Doxygen blocks rather than discarding it.

### Step 2 — Detect the language and load the reference

Identify the programming language, then read the corresponding file from
`references/` in this skill directory:

| Language                | Reference file             |
|-------------------------|----------------------------|
| Python                  | `references/python.md`     |
| TypeScript / JavaScript | `references/typescript.md` |
| Bash / Shell            | `references/bash.md`       |
| PHP                     | `references/php.md`        |
| C / C++                 | `references/c-cpp.md`      |
| Java                    | `references/java.md`       |
| Go                      | `references/go.md`         |
| Rust                    | `references/rust.md`       |

### Step 3 — Detect or ask about line length

Check the project for a preferred line length:

- `.editorconfig` → `max_line_length`
- `.prettierrc` / `prettier.config.*` → `printWidth`
- `pyproject.toml` → `[tool.ruff]` or `[tool.black]` `line-length`
- `phpcs.xml` / `.phpcs.xml` → `line_length`

If nothing is found and no preference has been stated, default to **80**.
Acceptable values: **80**, **100**, **120**.

### Step 4 — Write the comments

Follow the language reference for comment delimiters. Apply the universal
style rules below in all cases.

---

## Universal Style Rules

### Header blocks (file, class, struct, interface)

The opening line of every header block uses `/**` followed by dashes filling
to the configured line length:

```
/** ---------------------------------------------------------------------------
 * Example
 *
 * One-sentence summary of what this file provides.
 *
 * @author     Jane Doe <jane.doe@example.org>
 * @date       2024-01-15
 * ------------------------------------------------------------------------- */
```

Dash count = line_length − 4 (i.e. `/** ` is 4 chars, dashes fill the rest,
last char of the opening line is a dash — no trailing space).

Examples by line length:

- **80**:  `/** ` + 75 dashes → 79 chars total
- **100**: `/** ` + 95 dashes → 99 chars total
- **120**: `/** ` + 115 dashes → 119 chars total

### Function / method blocks

Regular `/** ... */` blocks (no dash line needed — the dash line is reserved
for file/class level):

```
/**
 * Validates an email address format.
 *
 * @details Checks the local-part and domain against RFC 5321 rules.
 *          Does NOT verify deliverability (no DNS lookup).
 *
 * @param  email  The raw email string to validate.
 * @return true if the format is valid, false otherwise.
 * @throws std::invalid_argument if email is empty.
 *
 * @note   Unicode domain names are not yet supported.
 * @see    parseEmail()
 */
```

Alignment tip: align the text after `@param` / `@return` / `@throws` at a
consistent column when there are multiple params — it aids readability.

---

## Universal Tags Reference

Use `@` prefix (classic Doxygen style) throughout.

| Tag                   | Purpose                                             |
|-----------------------|-----------------------------------------------------|
| `@details`            | Extended description (optional, separate paragraph) |
| `@param name`         | Describe one input parameter                        |
| `@param[in] name`     | Explicitly input-only (C/C++ convention)            |
| `@param[out] name`    | Output parameter (C/C++ pointer/reference)          |
| `@param[in,out] name` | Both input and output                               |
| `@return`             | Describe the return value                           |
| `@returns`            | Alias for `@return`                                 |
| `@throws ExcType`     | Exception that may be thrown (also `@exception`)    |
| `@note`               | Extra information the caller should know            |
| `@warning`            | Warn about footguns, side effects, thread-safety    |
| `@deprecated`         | Mark as deprecated; suggest the replacement         |
| `@since`              | Version or date when this was introduced            |
| `@author`             | Author name (file/class level)                      |
| `@version`            | Version string                                      |
| `@date`               | Date (ISO 8601 preferred: YYYY-MM-DD)               |
| `@see`                | Cross-reference to related item                     |
| `@todo`               | Future work                                         |
| `@bug`                | Known bug description                               |
| `@file`               | Documents the file itself (use in file header)      |
| `@class`              | Documents a class (when defined outside the class)  |
| `@fn`                 | Documents a function (when defined outside it)      |
| `@var`                | Documents a variable or constant                    |
| `@code` … `@endcode`  | Inline code example block                           |

---

## What to document

**Always document:**

- File headers (every source file)
- Public functions, methods, and constructors
- Public classes, structs, interfaces, enums
- Public constants and module-level variables with non-obvious purpose

**Document if non-obvious:**

- Private/internal functions with complex logic
- Parameters whose type alone doesn't convey intent

**Skip:**

- Trivial getters/setters where the name says everything
- Auto-generated or boilerplate code

---

## Quality principles

- Keep the description to a single sentence. No full stop needed.
- Use `@details` for anything that doesn't fit on one line.
- Mention side effects, global state mutations, and I/O in `@note` or `@warning`.
- If a parameter can be `null`/`None`/`undefined`, say so explicitly.
- Prefer active voice: *"Returns the user ID"* not *"The user ID is returned"*.
- Do not restate the obvious: `Adds two numbers` on `add(a, b)` is noise.
  Write what it actually does: `Adds two integers with overflow checking`.

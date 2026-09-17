# Doxygen Comments — Go

Go's native documentation tool is `godoc`, which uses plain `//` comments
immediately before a declaration. Doxygen can process Go files but requires
configuration (`EXTENSION_MAPPING = go=C` or an INPUT_FILTER).

**Important:** When the project uses `godoc` only (no Doxygen), follow the
godoc conventions below and skip the `@` tags. When Doxygen is explicitly
in use, use the `@` tags within `//` comments.

In both styles, the first sentence is the brief description — no `@brief`
tag is used.

---

## Godoc style (default for Go projects)

Godoc reads `//` comments immediately before declarations. No special
markers or tags — just plain prose. The first sentence is used as the
one-line summary. Exported identifiers must begin their comment with the
identifier name.

```go
// Package auth provides email validation and SMTP utilities.
package auth
```

```go
// EmailAddress stores a parsed and validated email address.
// The Local and Domain fields are always lower-cased.
type EmailAddress struct {
    // Local is the part before the '@'.
    Local string

    // Domain is the part after the '@', lower-cased.
    Domain string
}
```

```go
// Validate checks whether email conforms to RFC 5321 syntax.
// It returns false for empty strings and strings without a domain.
// DNS lookups are not performed.
//
// Example:
//
//	ok := Validate("user@example.com") // true
//	ok  = Validate("bad")              // false
func Validate(email string) bool {
    ...
}
```

---

## Doxygen-compatible style (when Doxygen is configured)

Use `//` comment lines with `@` tags. Place the block immediately before the
declaration.

### File / package header

```go
/** ---------------------------------------------------------------------------
 * auth/email_validator.go
 *
 * Email address validation utilities for the auth package.
 *
 * @author Jane Doe <jane.doe@example.org>
 * @date   2024-01-15
 * @version 1.0.0
 * ------------------------------------------------------------------------- */

// Package auth provides email validation and SMTP utilities.
package auth
```

### Struct

```go
// EmailAddress stores a parsed and validated email address.
//
// @details Both fields are always lower-cased during parsing.
//
// @since   1.0.0
type EmailAddress struct {
    // Local is the part before the '@'.
    Local string

    // Domain is the part after the '@', lower-cased.
    Domain string
}
```

### Function

```go
// Validate checks whether email conforms to RFC 5321 syntax.
//
// @details Checks the local-part and domain against RFC 5321 rules.
//          Does NOT verify deliverability.
//
// @param  email  The raw email string to validate.
// @return        True if the format is valid, false otherwise.
//
// @note   Returns false for empty strings.
func Validate(email string) bool {
    ...
}
```

### Function returning an error

```go
// SendVerificationEmail sends a verification email to the specified address.
//
// @param  recipient  Target email address (must be valid).
// @param  subject    Subject line; must not be empty.
// @param  timeout    SMTP response timeout.
// @return            nil on success; non-nil error describing the failure.
//
// @warning Opens a live network connection. Avoid in unit tests.
func SendVerificationEmail(
    recipient string,
    subject   string,
    timeout   time.Duration,
) error {
    ...
}
```

---

## Constants

```go
// MaxRetries is the maximum number of SMTP send attempts before giving up.
const MaxRetries = 3
```

*(Godoc style — exported constants are documented with a plain `//` comment
starting with the identifier name.)*

---

## Go-specific notes

- Go returns errors as values (`error` return), not exceptions. Use `@return`
  to describe what the error represents rather than `@throws`.
- Exported identifiers (upper-case) must be documented; unexported ones are
  optional but encouraged for complex logic.
- In godoc style, the comment for a func/type/const must begin with the
  identifier's name: `// Validate checks…`, `// EmailAddress stores…`.
- For Doxygen projects, use `EXTENSION_MAPPING = go=C` in the Doxyfile so
  Doxygen parses Go syntax correctly.

# Doxygen Comments — Rust

Rust's native documentation tool is `rustdoc`, which uses `///` (outer doc)
and `//!` (inner/module doc) comments. Doxygen has limited native Rust
support, so in practice Rust projects almost always use rustdoc.

This reference covers **rustdoc style with Doxygen-inspired tags** — the
pragmatic approach that works with `cargo doc` while keeping the intent of
structured Doxygen annotation. The first sentence of each comment is the
brief description — no `@brief` tag is used.

---

## Comment delimiters

| Style | Use |
|-------|-----|
| `///` | Outer doc — placed immediately before a declaration |
| `//!` | Inner doc — placed inside a module or crate (at the top of the file) |
| `/** ... */` | Outer block doc — equivalent to `///`, less common |
| `/*! ... */` | Inner block doc — equivalent to `//!`, less common |

---

## Module / file header (`//!`)

```rust
//! ---------------------------------------------------------------------------
//! Email address validation utilities for the auth module.
//!
//! @author    Jane Doe <jane.doe@example.org>
//! @date      2024-01-15
//! ---------------------------------------------------------------------------
```

*(The `//!` block at the top of the file documents the module itself.)*

---

## Struct

```rust
/// Represents a parsed and validated email address.
///
/// Both fields are always stored lower-cased.
///
/// # Examples
///
/// ```rust
/// let addr = EmailAddress::parse("User@Example.COM").unwrap();
/// assert_eq!(addr.domain, "example.com");
/// ```
pub struct EmailAddress {
    /// The local-part (before the `@`).
    pub local: String,

    /// The domain (after the `@`), lower-cased.
    pub domain: String,
}
```

---

## Function

```rust
/// Validates an email address string.
///
/// Checks the local-part and domain against RFC 5321 rules.
/// DNS lookups are **not** performed.
///
/// # Arguments
///
/// * `email` — The raw email string to validate.
///
/// # Returns
///
/// `true` if the format is valid, `false` otherwise.
///
/// # Panics
///
/// Does not panic; returns `false` on any input that can't be parsed.
///
/// # Examples
///
/// ```rust
/// assert!(validate("user@example.com"));
/// assert!(!validate("not-an-email"));
/// ```
pub fn validate(email: &str) -> bool {
    ...
}
```

---

## Function returning a Result

```rust
/// Sends a verification email to the specified address.
///
/// Opens an SMTP connection, transmits the message, and closes the
/// connection. Retries up to `MAX_RETRIES` times on transient failures.
///
/// # Arguments
///
/// * `recipient` — Target email address; must already be validated.
/// * `subject`   — Subject line; must not be empty.
/// * `timeout`   — SMTP response timeout.
///
/// # Returns
///
/// `Ok(())` on success. `Err(SmtpError)` on unrecoverable failure.
///
/// # Errors
///
/// * [`SmtpError::ConnectionFailed`] — TCP connection could not be established.
/// * [`SmtpError::Rejected`]         — MTA refused the message permanently.
///
/// # Panics
///
/// Panics if `subject` is empty.
pub fn send_verification_email(
    recipient: &EmailAddress,
    subject: &str,
    timeout: std::time::Duration,
) -> Result<(), SmtpError> {
    ...
}
```

---

## Enum

```rust
/// Possible outcomes of an email send operation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SendResult {
    /// Message accepted by the remote MTA.
    Accepted,

    /// MTA rejected the message (permanent failure).
    Rejected,

    /// Connection timed out; retry may succeed.
    Timeout,
}
```

---

## Trait

```rust
/// Abstracts email transport for testability.
///
/// Implement this trait to provide a mock transport in tests or to
/// swap SMTP for a different delivery mechanism.
pub trait EmailTransport {
    /// Sends a message via this transport.
    ///
    /// # Errors
    ///
    /// Returns `Err` if the transport cannot deliver the message.
    fn send(&self, message: &Message) -> Result<(), TransportError>;
}
```

---

## Constants

```rust
/// Maximum number of SMTP send attempts before giving up.
pub const MAX_RETRIES: u32 = 3;
```

---

## Rust-specific notes

- rustdoc uses Markdown inside `///` comments — headings, code blocks, bold,
  links all work.
- Standard rustdoc sections: `# Examples`, `# Errors`, `# Panics`,
  `# Safety` (for `unsafe` functions). Always include `# Examples` for
  public functions when practical — `cargo test` runs them.
- `# Safety` is required for every `unsafe fn` or function that requires
  the caller to uphold invariants.
- Errors: use `# Errors` to document every variant of the returned `Err`.
  List them with `[`VariantName`]` to generate hyperlinks.
- `@throws` is not idiomatic; use `# Errors` and `# Panics` instead.

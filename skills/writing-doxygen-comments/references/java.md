# Doxygen Comments — Java

Java uses `/** ... */` JavaDoc-style blocks. Doxygen parses these natively.
The first sentence is the brief description — no `@brief` tag needed.
The `@` tags are shared between JavaDoc and Doxygen, so existing JavaDoc
comments are largely compatible.

## Comment delimiter

```java
/**
 * One-line summary here.
 */
```

---

## File / package header

Java has no file-level `@file` tag in the classical sense — document the
primary public class or interface instead. For package-level docs use
`package-info.java`.

```java
/** ---------------------------------------------------------------------------
 * Email address validation utilities for the auth module.
 *
 * @author     Jane Doe <jane.doe@example.org>
 * @date       2024-01-15
 * ------------------------------------------------------------------------- */
package com.example.auth;
```

---

## Class / Interface

```java
/** ---------------------------------------------------------------------------
 * Validates and normalises email addresses.
 *
 * @details Parses RFC 5321 email syntax. Does not perform DNS lookups.
 *          Instances are immutable and thread-safe after construction.
 *
 * @since  1.0.0
 * ------------------------------------------------------------------------- */
public final class EmailValidator {

    /**
     * Creates a validator with default settings.
     */
    public EmailValidator() {}

    /**
     * Creates a validator with custom options.
     *
     * @param  options  Configuration options; must not be null.
     * @throws NullPointerException if options is null.
     */
    public EmailValidator(ValidatorOptions options) {
        ...
    }
}
```

---

## Method

```java
/**
 * Validates an email address string.
 *
 * @details Checks the local-part and domain against RFC 5321 rules.
 *          Does NOT verify deliverability (no DNS lookup performed).
 *
 * @param  email  The raw email string to validate; must not be null.
 * @return        true if the format is valid, false otherwise.
 * @throws IllegalArgumentException  If email is null or empty.
 *
 * @note   Punycode-encoded domains are accepted.
 * @see    #parseEmail(String)
 */
public boolean validate(String email) {
    ...
}
```

---

## Method with multiple parameters

```java
/**
 * Sends a verification email to the specified address.
 *
 * @details Opens an SMTP connection, sends the message, and closes it.
 *          Retries up to {@code MAX_RETRIES} times on transient failures.
 *
 * @param  recipient  Target email address; must be non-null and valid.
 * @param  subject    Subject line; must not be null or empty.
 * @param  timeoutMs  SMTP response timeout in milliseconds (use 0 for default).
 * @return            true if the MTA accepted the message.
 * @throws SmtpException             On unrecoverable connection failure.
 * @throws IllegalArgumentException  If subject is null or empty.
 *
 * @warning Opens a live network connection.
 *          Do not call from unit tests — inject a mock transport instead.
 *
 * @see    MockSmtpTransport
 */
public boolean sendVerificationEmail(
        String recipient,
        String subject,
        int    timeoutMs) throws SmtpException {
    ...
}
```

---

## Enum

```java
/**
 * Possible outcomes of an email send operation.
 *
 * @since  1.2.0
 */
public enum SendResult {
    /** Message accepted by the remote MTA. */
    ACCEPTED,

    /** MTA rejected the message (permanent failure). */
    REJECTED,

    /** Connection timed out; retry may succeed. */
    TIMEOUT,
}
```

---

## Constants / fields

```java
public final class SmtpConfig {

    /** Maximum number of SMTP send attempts before giving up. */
    public static final int MAX_RETRIES = 3;

    /**
     * Log verbosity level.
     *
     * Values: 0=silent, 1=error, 2=info, 3=debug.
     */
    private int logLevel = 2;
}
```

---

## Java-specific notes

- `@throws` (or `@exception`) — list checked exceptions in the `throws`
  clause; document unchecked exceptions (RuntimeException subclasses) too
  if they can reasonably be thrown.
- `{@code expr}` — use for inline code references inside prose.
- `{@link ClassName#method}` — use for cross-references within prose;
  `@see` is for standalone cross-reference lines.
- `@param` — always include; the type is already in the signature so the
  description should add meaning, not repeat the type.
- `@return` — omit for `void` methods; include for all others.
- For generic methods, document type bounds in `@details` when they are
  non-obvious from the signature alone.

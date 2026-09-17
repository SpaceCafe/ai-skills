# Doxygen Comments — TypeScript / JavaScript

TypeScript and JavaScript use `/** ... */` JSDoc-style block comments.
Doxygen parses these natively. The first sentence is the brief description
— no `@brief` tag needed.

## Comment delimiter

```ts
/**
 * One-line summary here.
 */
```

Single-line trivial docs can be written inline:
```ts
/** Maximum number of retry attempts. */
const MAX_RETRIES = 3;
```

---

## File header

```ts
/** ---------------------------------------------------------------------------
 * Email address validation utilities for the auth module.
 *
 * @author     Jane Doe <jane.doe@example.org>
 * @date       2024-01-15
 * ------------------------------------------------------------------------- */
```

---

## Interface / Type alias

```ts
/** ---------------------------------------------------------------------------
 * Represents a validated and parsed email address.
 *
 * @since  1.1.0
 * ------------------------------------------------------------------------- */
export interface EmailAddress {
    /** The local-part (before the `@`). */
    local: string;

    /** The domain (after the `@`), lower-cased. */
    domain: string;
}
```

---

## Class

```ts
/** ---------------------------------------------------------------------------
 * Validates and normalises email addresses.
 *
 * @details Parses RFC 5321 email syntax. Does not perform DNS lookups.
 *          Instantiate once and reuse — the regex is compiled on construction.
 *
 * @since  1.0.0
 * ------------------------------------------------------------------------- */
export class EmailValidator {
    /**
     * Creates a new validator.
     *
     * @param  options  Optional configuration overrides.
     */
    constructor(private readonly options: ValidatorOptions = {}) {}

    /**
     * Validates an email address string.
     *
     * @param  email  The raw email string to check.
     * @return        True if the format is valid, false otherwise.
     * @throws {TypeError} If email is null or undefined.
     *
     * @note   Punycode-encoded domains are accepted.
     */
    validate(email: string): boolean {
        ...
    }
}
```

---

## Standalone function

```ts
/**
 * Sends a verification email to the specified address.
 *
 * @details Opens an SMTP connection, transmits the message, and closes
 *          the connection. Retries up to MAX_RETRIES times on transient
 *          failures.
 *
 * @param  recipient  Parsed EmailAddress to send to.
 * @param  subject    Subject line; must not be empty.
 * @param  timeout    SMTP response timeout in milliseconds (default 5000).
 * @return            Resolves to true if the MTA accepted the message.
 * @throws {SMTPError}    On unrecoverable connection failure.
 * @throws {ValueError}   If subject is an empty string.
 *
 * @warning This function opens a live network connection.
 *          Do not call it in unit tests — use the mock transport instead.
 *
 * @see    MockTransport
 */
export async function sendVerificationEmail(
    recipient: EmailAddress,
    subject: string,
    timeout = 5000,
): Promise<boolean> {
    ...
}
```

---

## Enum

```ts
/**
 * Possible outcomes of an email send operation.
 */
export enum SendResult {
    /** Message accepted by the remote MTA. */
    Accepted = 'accepted',

    /** MTA rejected the message (permanent failure). */
    Rejected = 'rejected',

    /** Connection timed out; retry may succeed. */
    Timeout  = 'timeout',
}
```

---

## Constants

```ts
/** Maximum number of SMTP send attempts before giving up. */
export const MAX_RETRIES = 3;
```

---

## TypeScript-specific notes

- `@throws {ExceptionType}` — include the type in braces; it's parsed by
  TypeDoc and IDEs.
- For generic functions, mention type parameter constraints in `@details`
  if they are non-obvious.
- For `Promise`-returning functions, `@return` should describe the resolved
  value, not "a Promise of …" — the return type already says `Promise<T>`.
- Optional parameters (`param?: T`): note that `undefined` is acceptable
  and describe the default behaviour when omitted.

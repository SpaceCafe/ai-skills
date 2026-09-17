# Doxygen Comments — PHP

PHP uses `/** ... */` DocBlocks. Doxygen parses these natively and they are
also understood by PHPDoc / phpDocumentor. The first sentence is the brief
description — no `@brief` tag needed.

## Comment delimiter

```php
/**
 * One-line summary here.
 */
```

---

## File header

```php
<?php

/** ---------------------------------------------------------------------------
 * Email address validation utilities for the Auth module.
 *
 * @author     Jane Doe <jane.doe@example.org>
 * @date       2024-01-15
 * ------------------------------------------------------------------------- */

declare(strict_types=1);
```

---

## Class / Interface / Trait

```php
/** ---------------------------------------------------------------------------
 * Validates and normalises email addresses.
 *
 * @details Parses RFC 5321 email syntax. Does not perform DNS lookups.
 *          Instantiate once and reuse — the regex is compiled on construction.
 *
 * @since  1.0.0
 * ------------------------------------------------------------------------- */
class EmailValidator
{
    /** Compiled validation regex, shared across calls. */
    private readonly string $pattern;

    /**
     * Creates a new validator with optional configuration.
     *
     * @param  array<string, mixed>  $options  Optional overrides.
     */
    public function __construct(private array $options = []) {}

    /**
     * Validates an email address string.
     *
     * @param  string  $email  The raw email string to check.
     * @return bool            True if the format is valid, false otherwise.
     * @throws \InvalidArgumentException  If $email is empty.
     *
     * @note   Punycode-encoded domains are accepted.
     */
    public function validate(string $email): bool
    {
        ...
    }
}
```

---

## Standalone function

```php
/**
 * Sends a verification email to the specified address.
 *
 * @details Opens an SMTP connection, sends the message, and closes it.
 *          Retries up to MAX_RETRIES times on transient failures.
 *
 * @param  string  $recipient  Target email address (must be valid).
 * @param  string  $subject    Subject line; must not be empty.
 * @param  int     $timeout    SMTP response timeout in seconds (default 30).
 * @return bool                True if the MTA accepted the message.
 * @throws SMTPException       On unrecoverable connection failure.
 * @throws \ValueError         If $subject is an empty string.
 *
 * @warning Opens a live network connection.
 *          Do not call in unit tests — use the mock transport instead.
 *
 * @see    MockTransport
 */
function sendVerificationEmail(
    string $recipient,
    string $subject,
    int $timeout = 30
): bool {
    ...
}
```

---

## Properties

```php
class Config
{
    /** Maximum number of SMTP send attempts before giving up. */
    public const int MAX_RETRIES = 3;

    /**
     * Current log verbosity level.
     *
     * @var  int  0=silent, 1=error, 2=info, 3=debug.
     */
    private int $logLevel = 2;
}
```

---

## Enum (PHP 8.1+)

```php
/**
 * Possible outcomes of an email send operation.
 */
enum SendResult: string
{
    /** Message accepted by the remote MTA. */
    case Accepted = 'accepted';

    /** MTA rejected the message (permanent failure). */
    case Rejected = 'rejected';

    /** Connection timed out; retry may succeed. */
    case Timeout  = 'timeout';
}
```

---

## PHP-specific notes

- `@throws` — prefix with namespace when referencing built-in exceptions:
  `\InvalidArgumentException`, `\RuntimeException`, etc.
- `@param` — include the PHP type (`string`, `int`, `array<K,V>`, `?Type`)
  before the variable name: `@param string $name`.
- `@return` — include the PHP return type (`bool`, `void`, `static`, …).
- Nullable parameters (`?string $x`): state that `null` is accepted and what
  the default behaviour is when null is passed.
- `@var` on a property is the idiomatic way to document the type when it
  carries constraints that the type hint alone doesn't express.

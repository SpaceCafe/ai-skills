# Doxygen Comments — C / C++

C and C++ are Doxygen's native languages. All standard `/** ... */` blocks
and `///` single-line comments are supported out of the box. The first
sentence of each block is the brief description — no `@brief` tag needed.

## Comment delimiter

```cpp
/**
 * One-line summary.
 */
```

Or the triple-slash style for single items:
```cpp
/// One-line summary.
```

Use `/** */` blocks for everything that needs more than one line.

---

## File header

```c
/** ---------------------------------------------------------------------------
 * Email address validation routines for the auth subsystem.
 *
 * @author     Jane Doe <jane.doe@example.org>
 * @date       2024-01-15
 * ------------------------------------------------------------------------- */
```

---

## Struct / Union (C)

```c
/** ---------------------------------------------------------------------------
 * Stores a parsed and validated email address.
 *
 * @details Both fields point into the original input buffer.
 *          Do not free the struct without freeing that buffer.
 * ------------------------------------------------------------------------- */
typedef struct {
    /** The local-part (before the '\@'), NUL-terminated. */
    const char *local;

    /** The domain (after the '\@'), NUL-terminated, lower-cased. */
    const char *domain;
} EmailAddress;
```

---

## Class (C++)

```cpp
/** ---------------------------------------------------------------------------
 * Validates and normalises email addresses.
 *
 * @details Parses RFC 5321 email syntax. Does not perform DNS lookups.
 *          Thread-safe after construction — all methods are const.
 *
 * @since  1.0.0
 * ------------------------------------------------------------------------- */
class EmailValidator {
public:
    /**
     * Constructs a validator with optional configuration.
     *
     * @param  options  Configuration flags (see ValidatorOptions).
     */
    explicit EmailValidator(ValidatorOptions options = {});

    /**
     * Validates an email address string.
     *
     * @param[in]  email  NUL-terminated email string to check.
     * @return            true if the format is valid, false otherwise.
     * @throws std::invalid_argument  If email is nullptr or empty.
     *
     * @note   Punycode-encoded domains are accepted.
     */
    bool validate(const std::string& email) const;

private:
    ValidatorOptions options_;
};
```

---

## Function (C)

```c
/**
 * Validates an email address string.
 *
 * @details Checks the local-part and domain against RFC 5321 rules.
 *          Result is written to the out parameter on success.
 *
 * @param[in]  email  NUL-terminated input string; must not be NULL.
 * @param[out] out    Caller-allocated EmailAddress struct to populate.
 * @return            0 on success; -EINVAL if the format is invalid;
 *                    -ENOMEM if allocation fails.
 *
 * @warning The fields of @p out point into a copy of @p email that
 *          is allocated on the heap. Caller must call email_address_free().
 */
int email_validate(const char *email, EmailAddress *out);
```

---

## Function (C++) with in/out parameters

```cpp
/**
 * Sends a verification email.
 *
 * @param[in]      recipient  Target address (must be valid).
 * @param[in]      subject    Subject line; must not be empty.
 * @param[in,out]  ctx        SMTP context; updated with sent message count.
 * @return                    true if the MTA accepted the message.
 * @throws SmtpException      On unrecoverable connection failure.
 * @throws std::invalid_argument  If subject is empty.
 *
 * @warning Opens a live network connection. Not suitable for unit tests.
 * @see    MockSmtpContext
 */
bool sendVerificationEmail(
    const EmailAddress& recipient,
    const std::string&  subject,
    SmtpContext&        ctx);
```

---

## Enum

```cpp
/**
 * Possible outcomes of an email send operation.
 */
enum class SendResult {
    Accepted, ///< Message accepted by the remote MTA.
    Rejected, ///< MTA rejected the message (permanent failure).
    Timeout,  ///< Connection timed out; retry may succeed.
};
```

---

## Constants / macros

```c
/** Maximum number of SMTP send attempts before giving up. */
#define MAX_RETRIES 3

/** Default SMTP response timeout in seconds. */
static const int DEFAULT_TIMEOUT = 30;
```

---

## C/C++-specific notes

- `@param[in]`, `@param[out]`, `@param[in,out]` — use direction qualifiers
  for pointer and reference parameters; omit for value parameters.
- `@throws` (C++) — list the fully-qualified exception type.
- `@return` (C) — document every non-obvious return code, including errno
  values such as `-EINVAL`, `-ENOMEM`.
- For C: note ownership and lifetime requirements whenever heap memory is
  involved (who must free what, and when).
- `///` trailing comments on enum members and struct fields are idiomatic in
  C++ Doxygen and render inline in generated docs.

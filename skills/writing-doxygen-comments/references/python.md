# Doxygen Comments — Python

Python doesn't use `/* */` block comments. Doxygen processes Python source
either via its built-in Python parser or through a filter like `doxypypy`.
Both approaches are supported by this skill.

## Comment delimiter styles

### Style A — `##` prefix (native Doxygen, no filter needed)

Doxygen recognises lines starting with `##` as documentation comments when
`JAVADOC_AUTOBRIEF` is enabled. Place the block immediately before the
definition. The first sentence is the brief description — no `@brief` tag.

```python
## ---------------------------------------------------------------------------
## Utility helpers for the authentication module.
##
## @author     Jane Doe <jane.doe@example.org>
## @date       2024-01-15
## -------------------------------------------------------------------------
```

Function documentation (no dash lines — those are reserved for file/class level):

```python
## Validates an email address format.
#
# @details Checks the local-part and domain against RFC 5321 rules.
#          Does NOT verify deliverability (no DNS lookup).
#
# @param  email  The raw email string to validate.
# @return True if the format is valid, False otherwise.
# @throws ValueError if email is None or empty.
#
# @note   Unicode domain names are not yet supported.
def validate_email(email: str) -> bool:
    ...
```

### Style B — docstring with `@` tags (doxypypy / INPUT_FILTER)

If the project uses `doxypypy` as an `INPUT_FILTER`, standard Python triple-
quoted docstrings are parsed as Doxygen comments. First sentence is the brief.

```python
def validate_email(email: str) -> bool:
    """
    Validates an email address format.

    @details Checks the local-part and domain against RFC 5321 rules.
             Does NOT verify deliverability (no DNS lookup).

    @param  email  The raw email string to validate.
    @return True if the format is valid, False otherwise.
    @throws ValueError if email is None or empty.

    @note   Unicode domain names are not yet supported.
    """
    ...
```

**Pick style A by default** unless the project already uses docstrings with
`INPUT_FILTER`, in which case use style B.

---

## Class

```python
## Represents a parsed and validated email address.
#
# @details Stores the local-part and domain separately and exposes
#          helper methods for normalisation.
#
# @since  1.1.0
class EmailAddress:
    ...
```

---

## Method with multiple parameters

```python
## Sends a verification email to the given address.
#
# @param  recipient  EmailAddress to send to.
# @param  subject    Subject line; must not be empty.
# @param  timeout    Seconds to wait for SMTP response (default 30).
# @return True if the message was accepted by the MTA.
# @throws SMTPException  if the connection fails.
# @throws ValueError     if subject is empty.
#
# @warning Opens a live SMTP connection; do not call in unit tests.
def send_verification(
    recipient: "EmailAddress",
    subject: str,
    timeout: int = 30,
) -> bool:
    ...
```

---

## Constants / module-level variables

```python
## Maximum number of SMTP send attempts before giving up.
MAX_RETRIES: int = 3
```

---

## Python-specific notes

- `@throws` maps to Python exceptions; list the exception class name.
- For `Optional[T]` parameters, note that `None` is accepted: e.g.
  `@param token  Auth token, or None to use the environment default.`
- `@return` should describe what the value represents, not just its type —
  the type annotation already carries the type information.
- In style A, the `##` prefix marks the first line of a doc block; subsequent
  continuation lines use a single `#` with a leading space.

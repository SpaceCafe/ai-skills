---
name: writing-style
description: >
  Use when producing, editing, or reviewing any human-readable text: documentation, README files, code
  comments, commit messages, PR descriptions, emails, and changelogs. Covers American English spelling,
  ISO 8601 dates, professional tone, active voice, em-dash/en-dash avoidance, and list formatting. Apply
  proactively, not only when a style review is explicitly requested.
---

# Writing Style Guide

## Overview

Default style for all text this agent writes for a human to read. Covers locale, date format, tone,
dash usage, voice, and lists. When in doubt, match the existing document's conventions over these
defaults (see Language and locale below).

## Quick Reference

| Rule          | Do                                              | Don't                                                    |
|---------------|-------------------------------------------------|----------------------------------------------------------|
| Locale        | American English spelling ("color", "organize") | British spelling, unless the doc or user already uses it |
| Numeric dates | ISO 8601: `2026-04-22`                          | `04/22/2026` or `22/04/2026`                             |
| Tone          | Direct, confident, neutral                      | Sarcasm, slang, unnecessary hedging                      |
| Dashes        | Split sentences, semicolons, or parentheticals  | Em dash (—) or en dash (–) as a connector                |
| Voice         | Active: "The server returns an error"           | Passive: "An error is returned by the server"            |
| Sentences     | One or two clauses                              | Three or more clauses in one sentence                    |
| Lists         | Bullets for 3+ parallel items                   | Bullets for 1-2 items, or mismatched item structure      |

## Language and locale

Default to **American English** for all written output unless the user specifies a different language
or locale. This applies to spelling (e.g., "color" not "colour", "organize" not "organise"),
punctuation conventions, and date formats.

If the user writes in another language, match that language. If a document's existing content uses
British English or another locale, follow it for that document.

## Date format

When writing dates in numeric short form, use ISO 8601: `yyyy-mm-dd` (e.g., 2026-04-22). This avoids
ambiguity between mm/dd/yyyy and dd/mm/yyyy.

Written-out dates are fine in any natural order: "1st November", "November 1st", "22 April 2026".

## Tone

Keep the tone professional. This means:

- Clear and direct. State things plainly without hedging unnecessarily.
- Respectful and neutral. Avoid sarcasm, casual slang, or emotional language.
- Confident. Prefer assertive statements over passive, non-committal ones.

Professional does not mean stiff or bureaucratic. Short sentences and plain words serve the reader
better than formal-sounding complexity.

## No dashes as connectors

Never use em-dashes (—) or en-dashes (–) as sentence connectors or separators in prose. This
includes code comments, documentation, changelogs, and any other human-readable text.

Instead, use one of these approaches:

- Split into two sentences: "The build failed. The logs are in /tmp/build.log."
- Use a semicolon: "The build failed; the logs are in /tmp/build.log."
- Use a parenthetical: "The build failed (see logs in /tmp/build.log)."
- Reword to avoid the connector entirely.

Hyphens in compound words and identifiers are fine: "well-known", "open-source", `open_file_cache_valid`.

## Voice and sentence structure

Prefer active voice. Write "The server returns an error" rather than "An error is returned by the server."

Keep sentences short. If a sentence has more than two clauses, split it. Readers scan; dense paragraphs
slow them down.

## Bullet points and lists

Use bullet points when listing three or more parallel items. Prefer prose for one or two items.

Keep list items parallel in structure. If one item starts with a verb, all items should start with a verb.

Do not add trailing punctuation on bullet items unless the items are full sentences.

## Common mistakes

- **Em dash as a connector.** "The build failed — check the logs" reads as a shortcut. Split it into
  two sentences or use a semicolon instead.
- **Locale-format dates.** "04/22/2026" is ambiguous to half of all readers. Use `2026-04-22`.
- **Mismatched bullet structure.** Mixing verb-first items ("Run the tests") with noun-first items ("Test results") in
  the same list. Rewrite every item to the same pattern.
- **Passive voice that hides the actor.** "Errors are logged" doesn't say by what. Name the subject:
  "The middleware logs errors."
- **Hedging that adds no information.** "This might possibly cause an issue" says less than "This
  causes an issue" or "This can cause an issue under X." Keep a hedge only when it carries real
  uncertainty.

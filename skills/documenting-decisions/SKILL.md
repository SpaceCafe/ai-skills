---
name: documenting-decisions
description: Style guide for commenting configuration files (nginx, php.ini, Dockerfile, shell, TOML, YAML, Ansible) and source code (PHP, Python, Go, JavaScript, TypeScript). Apply when writing or reviewing any config or code file to ensure comments explain trade-offs and non-obvious decisions, not just what the directive or code does.
---

# Configuration comment style

**Heuristic:** Would a careful reviewer ask "why?" when they see this line? If yes, comment it. If the directive name
already answers the question, skip the comment.

## Placement and formatting rules

- Comments go **above** the statement, never trailing on the same line, even for single-line comments. Keeps lines
  short, avoids alignment churn, and makes comments easier to spot during review.
- Add a blank line **before** a comment (unless it sits at the top of a block). No blank line between the comment
  and its statement.
- Avoid dashes (en-dash, em-dash, hyphen) as separators in comment text. Use plain sentences instead.
- Wrap literal tokens (variable names, file paths, shell values, config keys, directive names) in backticks. Plain
  prose words stay unformatted.
- Wrap comment text to the format's conventional line limit: 80 for nginx/PHP ini/TOML/YAML/shell/Dockerfile, 100 for
  TypeScript/JavaScript/Go, 120 for PHP/Python.
- Use a **block** comment, not single-line, for: security trade-offs, deliberate deviations from a hardening
  baseline, or a decision with a "we tried X and it broke Y" history.
- If explaining the why needs more than 3-4 lines (architectural choices, rejected alternatives, compliance
  constraints), write an Architecture Decision Record instead and leave a one-line pointer comment.
- Self-evident directives, where the name already answers "why", get no comment at all.

See `references/examples.md` for the per-format syntax table and worked examples (nginx, PHP ini, TOML/YAML, PHP,
Python, Go, TypeScript/JavaScript).

## Keeping comments current

A stale comment is worse than no comment; it actively misleads.

- When a **value** changes, update the comment to reflect the new trade-off.
- When the **baseline** a file overrides changes, update any block comments that reference the old baseline.
- If the "why" no longer applies (e.g. the load balancer was removed), delete the comment.

## Ansible task documentation

Document Ansible tasks in the playbook or role above the task, never inside file content, templates, or inline
variables written to the target system. See `references/ansible.md` for the correct/incorrect pattern.

## Core rule

A future reader should understand the trade-off without needing to find the git blame.

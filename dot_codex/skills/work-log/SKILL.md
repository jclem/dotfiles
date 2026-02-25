---
name: work-log
description: Create and maintain dated work-log entries in /docs/logs using the required filename pattern and exact markdown template. Use when the user asks to log work, add a progress note, or record outcomes in a docs/logs markdown file.
---

# Work Log

Create logs in `/docs/logs` (repo-root relative path `docs/logs`) with deterministic naming and content format.

## Workflow

1. Ensure `docs/logs` exists.
2. Use the current local date in `YYYY-MM-DD` format unless the user explicitly gives a date.
3. Build the next filename index for that date:
- Match existing files: `YYYY-MM-DD-NN-*.md`
- `NN` is a 2-digit zero-padded increment starting at `01`
- Pick `max(NN) + 1` for that date
4. Build a slug from the title:
- Lowercase
- Replace spaces/punctuation with `-`
- Collapse repeated `-`
- Trim leading/trailing `-`
5. Create the file:
- `docs/logs/YYYY-MM-DD-NN-slug-title.md`

## Required File Body

Use this exact structure:

```md
# Title

Date:
Scope:

{content}
```

## Formatting Rules

- Keep the labels exactly `Date:` and `Scope:`.
- Keep one blank line after the title line.
- Keep one blank line between `Scope:` and the main content.
- Replace `Title`, `Date`, `Scope`, and `{content}` with concrete values.
- Keep logs concise and factual unless the user asks for more detail.

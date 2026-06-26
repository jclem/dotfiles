---
name: dotfiles-git-commit
description: Write and review Git commit messages for the dotfiles2 repository. Use when drafting a commit message, creating a commit, or checking whether commit text follows this repository's area-prefixed style.
---

# Dotfiles Git Commits

Inspect the changes and identify the configuration areas they affect.

Format the subject as `<areas>: <imperative statement>`:

- Use a short lowercase area name such as `fish` or `vim`.
- Use `repo` for changes related to this repository itself, such as repository metadata or agent configuration.
- Join multiple areas with commas and no spaces.
- Sort multiple areas alphabetically.
- Write one imperative statement after the prefix.
- Capitalise the first word of the statement.
- Omit final punctuation.

Examples:

```text
fish: Add vi settings to shell config
fish,vim: Align editor key bindings
repo: Add repository commit conventions
fish,repo: Document Fish configuration conventions
```

Omit a body for simple changes. When extra context is genuinely useful, add a blank line after the subject followed by one or two short, freeform paragraphs explaining the change.

---
name: write-fish-functions
description: Create, rewrite, and review Fish functions for the dotfiles repository using its standard file layout, documentation, argument parsing, long-form options, error handling, safety checks, and validation. Use whenever adding or modifying a file under dot_config/fish/functions.
---

# Write Fish Functions

Create one function per `dot_config/fish/functions/<function_name>.fish` file. Match the filename to the function name.

## Follow the standard structure

- Add a concise one-line comment above the function.
- Add a short `--description` to the function declaration.
- For user-invoked functions, parse arguments with `argparse --name=<function_name>` and an appropriate `--max-args` or `--min-args` constraint.
- Follow `argparse` immediately with `or return`.
- Use four-space indentation and accept `fish_indent`'s canonical formatting.

Use this shape even for small helpers:

```fish
# Describe the function's result or action.
function example --description "Describe the function"
    argparse --name=example --max-args=0 h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: example [OPTIONS]' \
            '' \
            'Describe what the function does.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    # Implementation
end
```

## Always provide help for user commands

Implement both `-h` and `--help` for every user-invoked function without exception, including functions that take no other options or arguments.

- Define `h/help` with `argparse`.
- Make both forms print identical help and return successfully without performing the function's normal action.
- Include usage, a concise explanation, and every option.
- Show short and long forms together, with `-h, --help` last.

Do not impose command-style argument parsing or help on Fish-owned callbacks such as `fish_prompt`. Preserve the callback protocol, accept or ignore Fish-provided arguments as appropriate, and add a comment explaining the exception.

## Prefer explicit syntax

- Use descriptive long options in implementations, such as `set --local`, `set --query`, `command --search --quiet`, and `docker image ls --all --quiet`.
- Allow a short user-facing option only when it also has a long form, such as `f/force`, and document both.
- Avoid opaque short-only flags. Prefer `printf` when output or newline behaviour matters; never introduce `echo -n`.
- Use local variables unless wider scope is intentional.
- Use single quotes for static text and double quotes when interpolation is required.

## Handle failures clearly

- Prefix errors with the function name, write them to stderr, and return nonzero.
- Check required external commands with `command --search --quiet` before use.
- Follow important external commands and command substitutions with `or return` so failures are not hidden.
- Reject unsupported options and unexpected positional arguments through `argparse`.

For destructive functions:

- Explain the destructive scope in help output.
- Display the selected resources before acting.
- Require explicit interactive confirmation by default.
- Provide a documented `-f`/`--force` option for intentional non-interactive use.
- Refuse to prompt in a non-interactive shell.
- Preserve built-in or protected resources explicitly.
- Never report success after a failed operation.

## Validate every function

Run all applicable checks before finishing:

```sh
fish --no-execute dot_config/fish/functions/<function_name>.fish
fish_indent --check dot_config/fish/functions/<function_name>.fish
fish --no-config -c 'source dot_config/fish/functions/<function_name>.fish; <function_name> -h'
fish --no-config -c 'source dot_config/fish/functions/<function_name>.fish; <function_name> --help'
```

For user-invoked functions, confirm that both help forms match. For Fish-owned callbacks, replace the help checks with focused callback-protocol tests. Add tests for normal output, invalid arguments, missing dependencies, and failure statuses where safe. Do not execute destructive operations merely to validate a function.

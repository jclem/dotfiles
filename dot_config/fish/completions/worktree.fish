complete -c worktree -f

set -l subcmds new list ls remove rm cd set help

complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a new    -d "Create a new worktree"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a list   -d "List worktrees"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a ls     -d "List worktrees"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a remove -d "Remove a worktree"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a rm     -d "Remove a worktree"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a cd     -d "Change to a worktree"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a set    -d "Set worktree metadata"
complete -c worktree -n "not __fish_seen_subcommand_from $subcmds" -a help   -d "Show help"

complete -c worktree -n "__fish_seen_subcommand_from rm remove" -a "(__wt_list_names)" -d "Worktree name"
complete -c worktree -n "__fish_seen_subcommand_from cd"        -a "(__wt_list_names)" -d "Worktree name"

complete -c worktree -n "__fish_seen_subcommand_from set; and not __fish_seen_subcommand_from note pr" -a note -d "Set a note"
complete -c worktree -n "__fish_seen_subcommand_from set; and not __fish_seen_subcommand_from note pr" -a pr   -d "Set a PR link"
complete -c worktree -n "__fish_seen_subcommand_from set; and __fish_seen_subcommand_from note pr" -a "(__wt_list_names)" -d "Worktree name"

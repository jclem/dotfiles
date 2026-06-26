# Print the current Git branch without a trailing newline.
function current_branch --description "Print the current Git branch"
    argparse --name=current_branch --max-args=0 h/help -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: current_branch [OPTIONS]' \
            '' \
            'Print the current Git branch without a trailing newline.' \
            '' \
            'Options:' \
            '  -h, --help  Show this help message'
        return
    end

    set --local branch (git symbolic-ref --quiet --short HEAD)
    or return

    printf '%s' $branch
end

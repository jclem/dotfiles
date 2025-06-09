function current_branch
    echo -n (git rev-parse --abbrev-ref HEAD)
end
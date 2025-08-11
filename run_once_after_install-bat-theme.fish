#!/opt/homebrew/bin/fish

# set -eu
set REPO "https://github.com/folke/tokyonight.nvim.git"
set REPO_NAME "tokyonight.nvim"
set BAT_THEMES_DIR (bat --config-dir)"/themes"
set THEME_DIR "extras/sublime"

if not test -d "$BAT_THEMES_DIR"
    mkdir -p "$BAT_THEMES_DIR"
end

cd "$BAT_THEMES_DIR"
if not test -d "$REPO_NAME"
    git clone --no-checkout --depth=1 --filter=blob:none "$REPO"
    cd "$REPO_NAME"
    git sparse-checkout set --no-cone "!/*" "$THEME_DIR"
    git checkout
else
    cd "$REPO_NAME"
    git fetch --filter=blob:none
    set updates (git rev-list HEAD..@{u} -- "$THEME_DIR")
    if test -n "$updates"
        git merge --ff-only --log
    end
end

command bat cache --build
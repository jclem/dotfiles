# Keep preferred executable directories at the front of PATH in priority order.
# https://fishshell.com/docs/current/cmds/fish_add_path.html
begin
    # Homebrew-managed executables
    set --local homebrew_paths /opt/homebrew/bin

    # User-installed and language-specific executables
    set --local user_paths \
        $HOME/.local/bin \
        $HOME/go/bin

    # Executables managed by individual tools
    set --local tool_paths $HOME/.atuin/bin

    fish_add_path --move \
        $homebrew_paths \
        $user_paths \
        $tool_paths
end

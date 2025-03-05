if test (uname) = Darwin
    fish_add_path --move \
		$HOME/.cache/.bun/bin \
        $HOME/bin \
        $HOME/.local/bin \
        $HOME/go/bin \
        $HOME/.atuin/bin \
        /opt/homebrew/bin \
        /opt/homebrew/opt/ruby/bin \
        /usr/local/bin
end

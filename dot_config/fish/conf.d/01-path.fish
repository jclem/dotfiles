if test (uname) = Darwin
    fish_add_path --move \
		$HOME/.cache/.bun/bin \
        $HOME/bin \
        $HOME/go/bin \
        /opt/homebrew/bin \
        /opt/homebrew/opt/ruby/bin \
        /usr/local/bin
end

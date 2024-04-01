if test (uname) = Darwin
    fish_add_path --move \
        $HOME/bin \
        $HOME/go/bin \
        /opt/homebrew/bin \
        /opt/homebrew/opt/ruby/bin
end

if test (uname) = Darwin
    fish_add_path --move \
        $HOME/bin \
        $HOME/go/bin \
        /usr/local/bin \
        /opt/homebrew/bin \
        /opt/homebrew/opt/ruby/bin
end

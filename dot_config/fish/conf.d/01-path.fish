if test (uname) = Darwin
    set -x PATH \
        $PATH \
        /opt/homebrew/bin \
        $HOME/.local/ \
        $HOME/go/bin
end

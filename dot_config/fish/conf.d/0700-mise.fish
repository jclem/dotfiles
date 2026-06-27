# Activate Mise when its executable is installed.
if test -x $HOME/.local/bin/mise
    $HOME/.local/bin/mise activate fish | source
end


set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin

if type -q pyenv
    pyenv init - fish | source
end

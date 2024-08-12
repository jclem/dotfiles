# Named such that it runs after "fzf.fish" installed by plugin.
#
# fzf_configure_bindings --help
#
# COMMAND            |  DEFAULT KEY SEQUENCE         |  CORRESPONDING OPTION
# Search Directory   |  Ctrl+Alt+F (F for file)      |  --directory
# Search Git Log     |  Ctrl+Alt+L (L for log)       |  --git_log
# Search Git Status  |  Ctrl+Alt+S (S for status)    |  --git_status
# Search History     |  Ctrl+R     (R for reverse)   |  --history
# Search Processes   |  Ctrl+Alt+P (P for process)   |  --processes
# Search Variables   |  Ctrl+V     (V for variable)  |  --variables

if type -q fzf_configure_bindings
    fzf_configure_bindings \
        --directory=\cf \
        --git_log=\co \
        --git_status=\cs \
        --history=\ch \
        --processes=\cp \
        --variables=\cv

    bind --mode insert \cr rg_fzf
end

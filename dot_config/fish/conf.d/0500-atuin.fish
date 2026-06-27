# Load Atuin's interactive shell integration when it is installed.
if status --is-interactive && command --query atuin
    atuin init fish | source
end

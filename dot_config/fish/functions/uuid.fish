function uuid
    uuidgen |\
        tr '[:upper:]' '[:lower:]' |\
        tr -d '[:space:]' |\
        tee /dev/tty |\
        pbcopy
end

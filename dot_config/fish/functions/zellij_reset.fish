function zellij_reset
  argparse --name=zellij_reset f/force h/help -- $argv

  if set -q _flag_h
    echo "Usage: zellij_reset [--force]"
    echo "Kill and delete all zellij sessions."
    echo "  -f, --force    Skip confirmation."
    return 0
  end

  if not command -sq zellij
    echo "zellij command not found."
    return 1
  end

  set -l sessions (zellij list-sessions 2>/dev/null)
  set -l session_count (count $sessions)

  if test $session_count -eq 0
    echo "No zellij sessions found."
    return 0
  end

  if not set -q _flag_f
    if not status is-interactive
      echo "Refusing to ask for confirmation in non-interactive mode. Use --force."
      return 1
    end

    echo "This will kill and delete all ($session_count) zellij sessions."
    for session in $sessions
      set -l cleaned_session (string trim $session)
      if test -n "$cleaned_session"
        echo "  - $cleaned_session"
      end
    end
    set -l confirm
    read -l -P "Type \"RESET ZELLIJ\" to confirm: " confirm

    if test "$confirm" != "RESET ZELLIJ"
      echo "Aborted."
      return 1
    end
  end

  zellij kill-all-sessions --yes
  zellij delete-all-sessions --yes
end

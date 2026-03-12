function zellij_clear_stdin_cache
  argparse --name=zellij_clear_stdin_cache h/help -- $argv

  if set -q _flag_h
    echo "Usage: zellij_clear_stdin_cache"
    echo "Remove Zellij's cached OSC 10/11 color responses."
    echo "Start a fresh Zellij session afterward so it can query the terminal again."
    return 0
  end

  set -l cache_roots \
    "$HOME/Library/Caches/org.Zellij-Contributors.Zellij" \
    "$XDG_CACHE_HOME/zellij"
  set -l removed 0

  if test -z "$XDG_CACHE_HOME"
    set cache_roots[2] "$HOME/.cache/zellij"
  end

  for cache_root in $cache_roots
    if not test -d "$cache_root"
      continue
    end

    for cache_file in (find "$cache_root" -type f -name stdin_cache 2>/dev/null)
      rm -f "$cache_file"
      set removed (math $removed + 1)
    end
  end

  if test $removed -eq 0
    echo "No Zellij stdin_cache files found."
  else
    echo "Removed $removed Zellij stdin_cache file(s). Start a fresh Zellij session to rebuild them."
  end
end

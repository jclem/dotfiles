function docker_nuke --description "Stop and remove all Docker resources"
  argparse --name=docker_nuke f/force v/volumes h/help -- $argv

  if set -q _flag_h
    echo "Usage: docker_nuke [--force] [--volumes]"
    echo "Stops all running containers, then removes containers, images, and networks."
    echo "  -f, --force    Skip confirmation."
    echo "  -v, --volumes  Remove volumes too."
    return 0
  end

  if not set -q _flag_f
    set -l prompt "This will stop all containers and delete Docker containers, images, and networks"

    if set -q _flag_v
      set prompt "$prompt, plus volumes"
    end

    set prompt "$prompt. Continue? [y/N] "
    read -l -P $prompt confirm

    if test "$confirm" != "y" -a "$confirm" != "Y"
      echo "Aborted."
      return 1
    end
  end

  set -l running (docker ps -q)
  if test (count $running) -gt 0
    docker stop $running
  end

  set -l containers (docker ps -aq)
  if test (count $containers) -gt 0
    docker rm -f $containers
  end

  set -l images (docker images -aq)
  if test (count $images) -gt 0
    docker image rm -f $images
  end

  set -l networks (docker network ls --format '{{.Name}}' | string match -v -r '^(bridge|host|none)$')
  if test (count $networks) -gt 0
    docker network rm $networks
  end

  if set -q _flag_v
    set -l volumes (docker volume ls -q)
    if test (count $volumes) -gt 0
      docker volume rm $volumes
    end
  end

  echo "Docker resources removed."
end

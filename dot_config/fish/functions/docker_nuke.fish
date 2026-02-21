function docker_nuke --description "Stop and remove all Docker resources"
  argparse --name=docker_nuke f/force v/volumes h/help -- $argv

  if set -q _flag_h
    echo "Usage: docker_nuke [--force] [--volumes]"
    echo "Stops all running containers, then removes containers, images, and networks."
    echo "  -f, --force    Skip confirmation."
    echo "  -v, --volumes  Remove volumes too."
    return 0
  end

  if not command -sq docker
    echo "docker command not found."
    return 1
  end

  if not docker info >/dev/null 2>&1
    echo "Docker daemon is not available."
    return 1
  end

  set -l docker_context (docker context show)
  set -l running (docker ps -q)
  set -l containers (docker ps -aq)
  set -l images (docker images -aq)
  set -l networks (docker network ls --format '{{.Name}}' | string match -v -r '^(bridge|host|none)$')
  set -l volumes (docker volume ls -q)

  set -l running_count (count $running)
  set -l container_count (count $containers)
  set -l image_count (count $images)
  set -l network_count (count $networks)
  set -l volume_count (count $volumes)

  set -l removable_volumes_count 0
  if set -q _flag_v
    set removable_volumes_count $volume_count
  end

  set -l total_count (math $running_count + $container_count + $image_count + $network_count + $removable_volumes_count)
  set -l stopped_count (math $container_count - $running_count)

  if test $total_count -eq 0
    echo "No Docker resources to remove."
    return 0
  end

  if not set -q _flag_f
    if not status is-interactive
      echo "Refusing to ask for confirmation in non-interactive mode. Use --force."
      return 1
    end

    echo "Context: $docker_context"
    echo "About to remove:"
    echo "  - $running_count running containers"
    echo "  - $stopped_count stopped containers"
    echo "  - $image_count images"
    echo "  - $network_count networks"
    if set -q _flag_v
      echo "  - $volume_count volumes"
    end

    set -l prompt "This will stop all containers and delete Docker containers, images, and networks"
    set prompt "$prompt, plus volumes if any."

    set prompt "$prompt Confirm by typing \"DESTROY DOCKER\" (exactly). "
    read -l -P $prompt confirm

    if test "$confirm" != "DESTROY DOCKER"
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

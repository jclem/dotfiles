# Stop and remove all Docker containers, images, and custom networks.
function docker_nuke --description "Stop and remove all Docker resources"
    argparse --name=docker_nuke --max-args=0 \
        f/force \
        v/volumes \
        h/help \
        -- $argv
    or return

    if set --query _flag_help
        printf '%s\n' \
            'Usage: docker_nuke [OPTIONS]' \
            '' \
            'Stop and remove all Docker containers, images, and custom networks.' \
            'Built-in networks are preserved.' \
            '' \
            'Options:' \
            '  -f, --force    Skip confirmation' \
            '  -v, --volumes  Remove volumes too' \
            '  -h, --help     Show this help message'
        return
    end

    if not command --search --quiet docker
        printf '%s\n' 'docker_nuke: Docker command not found' >&2
        return 1
    end

    if not docker info >/dev/null 2>&1
        printf '%s\n' 'docker_nuke: Docker daemon is not available' >&2
        return 1
    end

    set --local docker_context (docker context show)
    or return

    set --local running (docker container ls --quiet)
    or return

    set --local containers (docker container ls --all --quiet)
    or return

    set --local images (docker image ls --all --quiet)
    or return

    set --local networks (docker network ls --format '{{.Name}}')
    or return
    set networks (string match --invert --regex '^(bridge|host|none)$' $networks)

    set --local volumes
    if set --query _flag_volumes
        set volumes (docker volume ls --quiet)
        or return
    end

    set --local running_count (count $running)
    set --local container_count (count $containers)
    set --local stopped_count (math $container_count - $running_count)
    set --local image_count (count $images)
    set --local network_count (count $networks)
    set --local volume_count (count $volumes)
    set --local total_count (math $container_count + $image_count + $network_count + $volume_count)

    if test $total_count -eq 0
        printf '%s\n' 'No Docker resources to remove.'
        return
    end

    if not set --query _flag_force
        if not status is-interactive
            printf '%s\n' 'docker_nuke: Refusing to prompt in non-interactive mode; use --force' >&2
            return 1
        end

        printf '%s\n' \
            "Context: $docker_context" \
            'About to remove:' \
            "  - $running_count running containers" \
            "  - $stopped_count stopped containers" \
            "  - $image_count images" \
            "  - $network_count custom networks"

        if set --query _flag_volumes
            printf '%s\n' "  - $volume_count volumes"
        end

        set --local prompt 'This will stop and delete the listed Docker resources'
        if set --query _flag_volumes
            set prompt "$prompt, including volumes"
        end
        set prompt "$prompt. Confirm by typing \"DESTROY DOCKER\" exactly: "

        read --local --prompt-str $prompt confirmation
        if test "$confirmation" != 'DESTROY DOCKER'
            printf '%s\n' 'Aborted.'
            return 1
        end
    end

    set running (docker container ls --quiet)
    or return
    if test (count $running) -gt 0
        docker container stop $running
        or return
    end

    set containers (docker container ls --all --quiet)
    or return
    if test (count $containers) -gt 0
        docker container rm --force $containers
        or return
    end

    set images (docker image ls --all --quiet)
    or return
    if test (count $images) -gt 0
        docker image rm --force $images
        or return
    end

    set networks (docker network ls --format '{{.Name}}')
    or return
    set networks (string match --invert --regex '^(bridge|host|none)$' $networks)
    if test (count $networks) -gt 0
        docker network rm $networks
        or return
    end

    if set --query _flag_volumes
        set volumes (docker volume ls --quiet)
        or return
        if test (count $volumes) -gt 0
            docker volume rm $volumes
            or return
        end
    end

    printf '%s\n' 'Docker resources removed.'
end

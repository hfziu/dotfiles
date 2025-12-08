# Aliases psql and pg_dump to run inside the 'postgis' Docker container if it is running.
# NOTE: the aliases need to be explicitly sourced by calling `cont_pg` once in each fish shell session.

function cont_pg
    echo "psql and pg_dump commands are now aliased to run inside the 'postgis' container."
end

function _run_command_in_postgis_container
    set -l cmd $argv[1]
    set -e argv[1]

    # if not begin; type -q docker; and docker info > /dev/null 2>&1; and test -n (docker ps -q -f "name=^postgis\$"); end
    #     echo "Container 'postgis' is not running or Docker is unavailable; fallback to local $cmd." >&2
    #     command $cmd $argv
    #     return
    # end

    if test "$cmd" = "psql"
        docker exec -it postgis $cmd $argv
    else
        docker exec -i postgis $cmd $argv
    end
end

function psql --description 'Run psql inside postgis container'
    _run_command_in_postgis_container psql $argv
end

function pg_dump --description 'Run pg_dump inside postgis container'
    _run_command_in_postgis_container pg_dump $argv
end

#!/usr/bin/env bash

set -e

C9BIN=$(readlink -f "$0")
C9BINDIR=$(dirname "$C9BIN")
C9SERVICE=c9

function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

function get_default_port
{
    local sha=$(
        {
            echo $UID;
            echo $C9PROJECT;
        } | shasum
    )
    echo $(( 0x$(expr substr "$sha" 1 4) % 10000 + 40000 ))
}

export C9PROJECT="$(basename "$PWD")-c9"
export C9DIR="$PWD"
export C9SETTINGS="$HOME/.c9/user.settings"
DAEMON_FLAG='-d'
export COMPOSE_FILE="$C9BINDIR/docker-compose.yml"

while getopts 'rdp:s:' opt
do
    case $opt in
        p) C9PORT="$OPTARG";;
        P) C9PROJECT="$OPTARG";;
        d) DAEMON_FLAG=;;
        s) C9SERVICE="$OPTARG";;
        r) RESTART=1;;
    esac
done

shift $(( OPTIND - 1 ))

function opt_add_compose_file
{
    if [ -f "$1" ]
    then
        COMPOSE_FILE="$1:$COMPOSE_FILE"
    else
        return 1
    fi
}

function opt_add_path
{
    opt_add_compose_file "$1/docker-compose.c9.yml" ||
    opt_add_compose_file "$1/docker/docker-compose.c9.yml" ||
    opt_add_compose_file "$1/c9/docker-compose.yml"
}

if [ ! "$@" ]
then
    set up $DAEMON_FLAG "$C9SERVICE"
fi

opt_add_path "$HOME/.c9-docker/" || true
opt_add_path "$PWD/docker-compose.c9.yml" || true

export C9PORT=${C9PORT:-$(get_default_port)}
export C9AUTH=$(cat $HOME/.c9-auth)
export WORKSPACE=${C9DIR}
export C9_COMPOSE_PROJECT_NAME=${C9_COMPOSE_PROJECT_NAME:-$(basename "$C9DIR")}
export C9_COMPOSE_FILE=/workspace/docker-compose.yml:/workspace/docker/devel.yml

docker-compose -p "$C9PROJECT" build

if [ "$RESTART" ]
then
    docker-compose rm -fs
fi

echo "PORT = $C9PORT"
docker-compose -p "$C9PROJECT" "$@"


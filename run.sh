#!/usr/bin/env bash

set -eo pipefail

DC="${DC:-exec}"

# If we're running in CI we need to disable TTY allocation for docker-compose
# commands that enable it by default, such as exec and run.
TTY=""
if [[ ! -t 1 ]]; then
    TTY="-T"
fi

# -----------------------------------------------------------------------------
# Helper functions start with _ and aren't listed in this script's help menu.
# -----------------------------------------------------------------------------

function _dc {
    export DOCKER_BUILDKIT=1
    docker-compose ${TTY} "${@}"
}

function _use_env {
    sort -u environment/local.env | grep -v '^$\|^\s*\#' > './environment/local.env.tempfile'
    export $(cat environment/local.env.tempfile | xargs)
    rm environment/local.env.tempfile
}

# ----------------------------------------------------------------------------
# * General functions.

function up {
   echo "up"
}

function proto:go {
    protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    protos/helloworld.proto
}

function proto:py {
    python -m grpc_tools.protoc -I protos --python_out=./protos --grpc_python_out=./protos protos/helloworld.proto
}

# -----------------------------------------------------------------------------

function help {
    printf "%s <task> [args]\n\nTasks:\n" "${0}"

    compgen -A function | grep -v "^_" | cat -n
}

TIMEFORMAT=$'\nTask completed in %3lR'
time "${@:-help}"

#!/usr/bin/env bash

readonly CONFIG_DIR="$ROOT_DIR/config"
readonly SCRIPTS_DIR="$ROOT_DIR/scripts"

create_temp_directory() {
    mktemp -d
}

remove_temp_directory() {
    [[ -n "$1" && -d "$1" ]] && rm -rf -- "$1"
}

fail() {
    printf '[ERROR] %s\n' "$*" >&2
    exit 1
}

require_programs() {
    local program

    for program in "$@"; do
        command -v "$program" >/dev/null 2>&1 ||
            fail "Required program missing: $program"
    done
}

install_packages() {
    doas emerge --verbose "$@"
}

remove_packages() {
    doas emerge --depclean --ask --verbose "$@"
}

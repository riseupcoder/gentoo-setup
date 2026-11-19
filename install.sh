#!/usr/bin/env bash

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$ROOT_DIR/lib"

source "$LIB_DIR/common.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/filesystem.sh"
# source "$LIB_DIR/selinux.sh"

readonly SETUP_SCRIPTS=(
    "scripts/create_session.sh:configure_sessions"
    "scripts/setup_desktop.sh:setup_desktop"
    "scripts/security/setup_harden_network.sh:setup_harden_network"
    "scripts/security/setup_harden_system.sh:setup_harden_system"
)

for entry in "${SETUP_SCRIPTS[@]}"; do
    IFS=':' read -r script function <<< "$entry"

    info "Running $(basename "$script")"

    source "$ROOT_DIR/$script"

    "$function"
done

success "Gentoo setup completed."

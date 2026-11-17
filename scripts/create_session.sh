#!/usr/bin/env bash

set -euo pipefail

install_session_script() {
    local source="$CONFIG_DIR/system/openrc/session/create-session.start"

    info "Installing session startup script..."

    require_file "$source"

    doas install -D -m 0755 \
        "$source" \
        /etc/local.d/create-session.start

    grep -q 'XDG_RUNTIME_DIR' ~/.bash_profile 2>/dev/null || \
        echo 'export XDG_RUNTIME_DIR=/run/user/$(id -u)' >> ~/.bash_profile

    success "Session startup script installed."
}

configure_sessions() {
    install_session_script

    info "Enabling session initialization at boot..."

    doas rc-update add local default

    success "Session initialization enabled at boot."
}

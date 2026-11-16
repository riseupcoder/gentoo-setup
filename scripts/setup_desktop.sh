#!/usr/bin/env bash

set -euo pipefail

readonly PACKAGE_USE_DIR="$CONFIG_DIR/portage/package.use"

setup_seatd() {
    info "Installing seatd..."

    require_file "$PACKAGE_USE_DIR/seatd"

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/seatd" \
        /etc/portage/package.use/seatd

    install_packages sys-auth/seatd

    doas rc-update add seatd default
    doas usermod -aG video,seat "$(id -un)"

    success "seatd installed and configured."
}

setup_wlroots() {
    info "Installing wlroots..."

    require_file "$PACKAGE_USE_DIR/wlroots"

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/wlroots" \
        /etc/portage/package.use/wlroots

     install_packages gui-libs/wlroots

    success "wlroots installed and configured."
}

setup_dwl() {
    info "Installing dwl..."

    require_file "$PACKAGE_USE_DIR/dwl"
    require_file "$CONFIG_DIR/portage/package.accept_keywords/dwl"
    require_file "$CONFIG_DIR/portage/savedconfig/gui-wm/dwl"

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/dwl" \
        /etc/portage/package.use/dwl

    doas install -D -m 0644 \
        "$CONFIG_DIR/portage/package.accept_keywords/dwl" \
        /etc/portage/package.accept_keywords/dwl

    doas install -D -m 0644 \
        "$CONFIG_DIR/portage/savedconfig/gui-wm/dwl" \
        /etc/portage/savedconfig/gui-wm/dwl

    install_packages gui-wm/dwl

    success "dwl installed with custom configuration."
}

setup_pipewire() {
    info "Installing PipeWire and WirePlumber..."

    require_file "$PACKAGE_USE_DIR/pipewire"
    require_file "$PACKAGE_USE_DIR/wireplumber"

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/pipewire" \
        /etc/portage/package.use/pipewire

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/wireplumber" \
        /etc/portage/package.use/wireplumber

    install_packages media-video/pipewire media-video/wireplumber

    rc-update add -U pipewire default
    rc-update add -U pipewire-pulse default
    rc-update add -U wireplumber default

    success "PipeWire and WirePlumber installed and configured."
}

setup_podman() {
    info "Installing Podman and podman-compose..."

    install_packages app-containers/podman app-containers/podman-compose

    success "Podman and podman-compose installed."
}

setup_foot() {
    info "Installing Foot terminal..."

    require_file "$PACKAGE_USE_DIR/foot"
    require_file "$CONFIG_DIR/portage/package.accept_keywords/foot"

    doas install -D -m 0644 \
        "$PACKAGE_USE_DIR/foot" \
        /etc/portage/package.use/foot

    doas install -D -m 0644 \
        "$CONFIG_DIR/portage/package.accept_keywords/foot" \
        /etc/portage/package.accept_keywords/foot

    install_packages gui-apps/foot
  
    install -Dm600 \
      "$CONFIG_DIR/desktop/foot/foot.ini" \
      "$HOME/.config/foot/foot.ini"

    success "Foot terminal installed."
}

install_font() {
    local font_dir="$HOME/.local/share/fonts"
    local url digest

    info "Installing Google Sans Code..."

    install_packages app-arch/unzip

    create_temp_directory

    read -r url digest < <(
        curl -fsSL --retry 3 \
            https://api.github.com/repos/googlefonts/googlesans-code/releases/latest |
            jq -er '
                .assets[]
                | select(.name | test("^GoogleSansCode-v[0-9.]+\\.zip$"))
                | [.browser_download_url, .digest]
                | @tsv
            '
    )

    curl -fsSL --retry 3 -o "$TEMP_DIR/font.zip" "$url"

    printf '%s  %s\n' "${digest#sha256:}" "$TEMP_DIR/font.zip" |
        sha256sum -c -

    unzip -jo "$TEMP_DIR/font.zip" '*.ttf' -d "$TEMP_DIR" >/dev/null

    install -Dm400 \
        "$TEMP_DIR/GoogleSansCode[MONO,wght].ttf" \
        "$font_dir/google_sans_code.ttf"

    fc-cache -f "$font_dir"

    remove_temp_directory

    remove_packages app-arch/unzip

    success "Google Sans Code installed."
}

setup_desktop() {
    setup_seatd
    setup_wlroots
    setup_dwl

    setup_pipewire

    setup_podman

    setup_foot
    install_font

    echo
    success "Wayland desktop configuration complete."
}

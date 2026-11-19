#!/usr/bin/env bash

set -euo pipefail

setup_nftables() {
    info "Setting up nftables"

    install_packages net-firewall/nftables

    # Install firewall configurations.
    doas install -Dm644 -C \
        "$CONFIG_DIR/system/network/nftables/base-firewall.nft" \
        /etc/nftables/base-firewall.nft

    doas install -Dm644 -C \
        "$CONFIG_DIR/system/network/nftables/geoblock.nft" \
        /etc/nftables/geoblock.nft

    # Define the persistent ruleset.
    doas install -Dm600 /dev/stdin \
        /var/lib/nftables/rules-save <<'EOF'
include "/etc/nftables/base-firewall.nft"
include "/etc/nftables/geoblock.nft"
EOF

    # Validate the complete ruleset before activation.
    doas nft -c -f /var/lib/nftables/rules-save

    # Enable nftables through OpenRC.
    doas rc-update add nftables default

    if doas rc-service nftables status >/dev/null 2>&1; then
        doas rc-service nftables reload
    else
        doas rc-service nftables start
    fi

    success "nftables configured and loaded"
}

setup_geoblock() {
    info "Setting up GeoBlock"

    install_packages net-misc/curl

    # Install the independent updater.
    doas install -Dm755 -C \
        "$LIBEXEC_DIR/security/geoblock-update" \
        /usr/local/libexec/geoblock-update

    # Install OpenRC service.
    doas install -Dm755 -C \
        "$CONFIG_DIR/system/openrc/geoblock/geoblock-update" \
        /etc/init.d/geoblock-update

    # Run once at boot and update the current installation.
    doas rc-update add geoblock-update default
    doas rc-service geoblock-update start

    success "GeoBlock configured"
}

setup_unbound() {
    info "Setting up Unbound DNS forwarder"

    install_packages net-dns/unbound

    # Install Unbound configuration.
    doas install -Dm644 -C \
        "$CONFIG_DIR/system/network/unbound/unbound.conf" \
        /etc/unbound/unbound.conf

    doas -u unbound unbound-anchor -a /var/lib/unbound/root.key

    # Validate configuration.
    doas unbound-checkconf /etc/unbound/unbound.conf

    # Enable Unbound through OpenRC.
    doas rc-update add unbound default
    doas rc-service unbound start

    success "Unbound DNS forwarder configured"
}

setup_dnsmasq() {
    info "Configuring dnsmasq"

    install_packages net-dns/dnsmasq

    doas install -d -m 755 /etc/dnsmasq.d

    # Install dnsmasq configuration.
    doas install -Dm644 /dev/stdin \
        /etc/dnsmasq.conf <<'EOF'
listen-address=127.0.0.1
bind-interfaces
port=53
no-resolv
cache-size=10000
server=127.0.0.1#5353
conf-dir=/etc/dnsmasq.d/,*.conf
EOF

    # Validate configuration before activation.
    doas dnsmasq --test

    # Enable dnsmasq through OpenRC.
    doas rc-update add dnsmasq default
    doas rc-service dnsmasq start

    # Configure local DNS resolution.
    doas rm -f /etc/resolv.conf

    doas install -Dm644 /dev/stdin \
        /etc/resolv.conf <<'EOF'
nameserver 127.0.0.1
EOF

    doas chattr +i /etc/resolv.conf
    success "dnsmasq configured"
}

setup_hagezi_blocklist() {
    info "Setting up HaGeZi DNS blocklists"

    install_packages net-misc/curl

    doas install -d -m 755 /etc/dnsmasq.d/

    # Install independent updater.
    doas install -Dm755 -C \
      "$LIBEXEC_DIR/security/hagezi-update" \
      /usr/local/libexec/hagezi-update

   doas install -Dm755 -C \
      "$CONFIG_DIR/system/openrc/hagezi/hagezi-update" \
      /etc/init.d/hagezi-update

    doas rc-update add hagezi-update default
    doas rc-service hagezi-update start

    success "HaGeZi DNS blocklists configured"
}

setup_harden_network() {
    info "Applying network hardening"

    # Firewall policy must exist before GeoBlock updates its sets.
    setup_nftables
    setup_geoblock

    # Establish the DNS forwarding chain.
    setup_unbound
    setup_dnsmasq

    # Populate DNS filtering rules.
    setup_hagezi_blocklist

    success "Network hardening complete"
}


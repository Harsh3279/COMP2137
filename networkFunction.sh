# network_functions.sh
# This file contains functions for reporting network configuration details.
# Intended to be sourced by other scripts.

# Function to display IP addresses for all interfaces
show_ip_addresses() {
    echo "---- IP Address Information ----"
    ip -brief address
    echo
}

# Function to display default gateway
show_default_gateway() {
    echo "---- Default Gateway ----"
    ip route | grep default
    echo
}

# Function to display DNS servers
show_dns_servers() {
    echo "---- DNS Server Configuration ----"
    grep -E '^nameserver' /etc/resolv.conf
    echo
}

# Function to display active network interfaces
show_active_interfaces() {
    echo "---- Active Network Interfaces ----"
    ip link show up | awk -F: '/^[0-9]+:/{print $2}' | sed 's/^[ \t]*//'
    echo
}

# Function to display hostname and domain
show_hostname_and_domain() {
    echo "---- Hostname and Domain ----"
    hostname
    hostname -d 2>/dev/null
    echo
}

# Function to generate full network report
generate_network_report() {
    echo "========== Network Configuration Report =========="
    show_hostname_and_domain
    show_ip_addresses
    show_default_gateway
    show_dns_servers
    show_active_interfaces
    echo "=================================================="
}


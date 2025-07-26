# hardware_functions.sh
# This file contains functions for gathering hardware info.
# It is intended to be sourced, not executed directly.

# Function to display CPU info
cpu_info() {
    echo "---- CPU Information ----"
    lscpu | grep -E 'Model name|Socket|Thread|Core|Architecture'
    echo
}

# Function to display Memory info
memory_info() {
    echo "---- Memory Information ----"
    free -h
    echo
}

# Function to display Disk info
disk_info() {
    echo "---- Disk Information ----"
    lsblk
    echo
}

# Function to display Network info
network_info() {
    echo "---- Network Interfaces ----"
    ip -brief address
    echo
}

# Function to generate full report
generate_hardware_summary() {
    echo "========== Hardware Summary Report =========="
    cpu_info
    memory_info
    disk_info
    network_info
    echo "============================================="
}


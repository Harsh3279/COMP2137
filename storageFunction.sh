# storage_functions.sh
# This file contains functions for gathering storage information.
# Intended to be sourced by other scripts.

# Function to show mounted filesystems and usage
show_filesystem_usage() {
    echo "---- Filesystem Disk Usage ----"
    df -hT | grep -v tmpfs
    echo
}

# Function to show block devices
show_block_devices() {
    echo "---- Block Devices ----"
    lsblk
    echo
}

# Function to show disk partitions
show_disk_partitions() {
    echo "---- Partition Info ----"
    fdisk -l 2>/dev/null | grep -E '^Disk /|Device|/dev/'
    echo
}

# Function to show LVM info (if available)
show_lvm_info() {
    if command -v lvdisplay >/dev/null; then
        echo "---- LVM Volumes ----"
        lvdisplay
        echo
    fi
}

# Function to generate the full storage report
generate_storage_report() {
    echo "========== Storage Management Report =========="
    show_filesystem_usage
    show_block_devices
    show_disk_partitions
    show_lvm_info
    echo "==============================================="
}


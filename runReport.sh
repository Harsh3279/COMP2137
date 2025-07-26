#!/bin/bash
# run_report.sh
# Master script to run system reports

# Source the function files
source ./hardwareFunctions.sh
source ./storageFunction.sh
source ./networkFunction.sh

# Function to display the menu
show_menu() {
    echo "Please choose a report to run:"
    echo "1) Hardware Report"
    echo "2) Storage Report"
    echo "3) Network Report"
    read -p "Enter your choice [1-3]: " choice
    case "$choice" in
        1) generate_hardware_summary ;;
        2) generate_storage_report ;;
        3) generate_network_report ;;
        *) echo "Invalid choice." ;;
    esac
}

# Check command-line argument
if [[ -n "$1" ]]; then
    case "$1" in
        hardware) generate_hardware_summary ;;
        storage) generate_storage_report ;;
        network) generate_network_report ;;
        *) echo "Unknown report: $1"
           echo "Valid options: hardware, storage, network"
           ;;
    esac
else
    show_menu
fi


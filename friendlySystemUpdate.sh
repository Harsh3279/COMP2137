#!/bin/bash

LOGFILE="/tmp/yourscriptname.$$"

echo "Starting script... Logging to $LOGFILE"

# Task 1: Check root
if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root (use sudo)."
    echo "Script was not run as root." >> "$LOGFILE"
    exit 1
fi

echo "Confirmed: Running as root." >> "$LOGFILE"

# Task 2: Run apt update
echo "Running apt update..."
apt update >> "$LOGFILE" 2>&1
if [ $? -ne 0 ]; then
    echo "apt update failed. Please check your network or sources."
    echo "apt update command failed." >> "$LOGFILE"
    exit 1
fi
echo "apt update completed successfully." >> "$LOGFILE"

# Task 3: Count upgradable packages
UPGRADABLE_COUNT=$(apt list --upgradable 2>/dev/null | grep -v Listing | wc -l)
echo "There are $UPGRADABLE_COUNT packages available for update."

# Task 4: Show free space on root before upgrade
FREE_SPACE=$(df -h / | awk 'NR==2 {print $4}')
echo "Free space on root filesystem before upgrade: $FREE_SPACE"

# Ask user if they want to proceed
read -p "Do you want to proceed with upgrading these packages? (y/n): " ANSWER

if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" && "$ANSWER" != "yes" ]]; then
    echo "User chose not to upgrade packages."
    echo "Upgrade aborted by user." >> "$LOGFILE"
    exit 0
fi

echo "User agreed to upgrade packages."
echo "Proceeding with upgrade..." >> "$LOGFILE"

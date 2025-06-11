#!/bin/bash

LOGFILE="/tmp/friendlySystemUpdate.$$"

echo "Starting script... Logging to $LOGFILE"

# Task 1: Check if script is run as root
if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root (use sudo)."
    echo "Script was not run as root." >> "$LOGFILE"
    exit 1
fi

echo "Confirmed: Running as root." >> "$LOGFILE"

# Task 2: Run apt update
echo "Running apt update..."
apt update >> "$LOGFILE"
apt_update_status=$?

if [ $apt_update_status -ne 0 ]; then
    echo "apt update failed. Please check your network or sources."
    echo "apt update command failed with status $apt_update_status." >> "$LOGFILE"
    exit 1
fi

echo "apt update completed successfully." >> "$LOGFILE"

# Task 3: Count upgradable packages
UPGRADABLE_COUNT=$(apt list --upgradable 2> /tmp/tmp_err.$$ | grep -v Listing | wc -l)
cat /tmp/tmp_err.$$ >> "$LOGFILE"
rm -f /tmp/tmp_err.$$
echo "There are $UPGRADABLE_COUNT packages available for update."

# Task 4: Show free space before upgrade
FREE_SPACE_BEFORE=$(df -h / | awk 'NR==2 {print $4}')
echo "Free space on root filesystem before upgrade: $FREE_SPACE_BEFORE"

# Ask if user wants to proceed
read -p "Do you want to proceed with upgrading these packages? (y/n): " ANSWER

if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "User chose not to upgrade packages."
    echo "Upgrade aborted by user." >> "$LOGFILE"
    exit 0
fi

echo "User agreed to upgrade packages."
echo "Running apt upgrade..." >> "$LOGFILE"

# Task 5: Run apt upgrade
echo "Upgrading packages..."
apt upgrade -y >> "$LOGFILE"
apt_upgrade_status=$?

if [ $apt_upgrade_status -ne 0 ]; then
    echo "apt upgrade failed. Please check the log for details."
    echo "apt upgrade command failed with status $apt_upgrade_status." >> "$LOGFILE"
    exit 1
fi

echo "apt upgrade completed successfully." >> "$LOGFILE"
echo "Upgrade completed successfully."

# Task 6: Show free space after upgrade
FREE_SPACE_AFTER=$(df -h / | awk 'NR==2 {print $4}')
echo "Free space on root filesystem after upgrade: $FREE_SPACE_AFTER"


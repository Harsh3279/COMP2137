#!/bin/bash

echo "Starting script..."

# Task 1: Check if running as root
if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root (use sudo)."
    exit 1
fi

# Task 2: Check free space on root filesystem
USED_PERCENT=$(df / | awk 'NR==2 {gsub("%",""); print $5}')
FREE_PERCENT=$((100 - USED_PERCENT))

if [ "$FREE_PERCENT" -ge 50 ]; then
    echo "✅ Root filesystem has $FREE_PERCENT% free space. No action needed."
    exit 0
fi

echo "⚠️ Root filesystem is only $FREE_PERCENT% free. Finding largest files..."

# Task 3: Display 20 largest files owned by users with UID >= 1000
echo -e "\nTop 20 largest regular files in / owned by UID ≥ 1000:"
echo -e "Size(MB)\tOwner\t\tPath"
echo "--------------------------------------------------------------"

find / -xdev -type f -printf '%s %u %p\n' 2>/dev/null | \
while read size owner path; do
    OWNER_UID=$(id -u "$owner" 2>/dev/null)
    if [ "$OWNER_UID" -ge 1000 ] 2>/dev/null; then
        SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $size/1024/1024}")
        printf "%-9s\t%-10s\t%s\n" "$SIZE_MB" "$owner" "$path"
    fi
done | sort -nr | head -n 20


exit 0


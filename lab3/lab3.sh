#!/bin/bash
# lab3.sh: Deploy and run configure-host.sh on two servers, update local /etc/hosts
# Usage: sudo ./lab3.sh [-verbose]

VERBOSE=0
if [[ "$1" == "-verbose" ]]; then
  VERBOSE=1
fi

USER="remoteadmin"
#SERVER1="server1"
#SERVER2="server2"
SERVER1="192.168.16.10"   # your current temp IP for server1
SERVER2="192.168.16.11"   # your current temp IP for server2
SERVER1_IP="192.168.16.10"
SERVER2_IP="192.168.16.11"
SCRIPT="configure-host.sh"

vprint() {
  if [[ $VERBOSE -eq 1 ]]; then
    echo "$1"
  fi
}

check_success() {
  if [[ $? -ne 0 ]]; then
    echo "Error: $1 failed." >&2
    exit 1
  fi
}

vprint "Copying $SCRIPT to $SERVER1..."
scp "$SCRIPT" "$USER@$SERVER1:/root/"
check_success "SCP to $SERVER1"

vprint "Setting execute permission on $SERVER1..."
ssh "$USER@$SERVER1" "chmod +x /root/$SCRIPT"
check_success "chmod on $SERVER1"

vprint "Running $SCRIPT on $SERVER1..."
CMD="/root/$SCRIPT -name loghost -ip $SERVER1_IP -hostentry webhost $SERVER2_IP"
[[ $VERBOSE -eq 1 ]] && CMD="$CMD -verbose"
ssh "$USER@$SERVER1" -- $CMD
check_success "Remote execution on $SERVER1"

vprint "Copying $SCRIPT to $SERVER2..."
scp "$SCRIPT" "$USER@$SERVER2:/root/"
check_success "SCP to $SERVER2"

vprint "Setting execute permission on $SERVER2..."
ssh "$USER@$SERVER2" "chmod +x /root/$SCRIPT"
check_success "chmod on $SERVER2"

vprint "Running $SCRIPT on $SERVER2..."
CMD="/root/$SCRIPT -name webhost -ip $SERVER2_IP -hostentry loghost $SERVER1_IP"
[[ $VERBOSE -eq 1 ]] && CMD="$CMD -verbose"
ssh "$USER@$SERVER2" -- $CMD
check_success "Remote execution on $SERVER2"

vprint "Updating local /etc/hosts..."
LOCAL_CMD="./$SCRIPT -hostentry loghost $SERVER1_IP"
[[ $VERBOSE -eq 1 ]] && LOCAL_CMD="$LOCAL_CMD -verbose"
sudo $LOCAL_CMD
check_success "Local hostentry for loghost"

LOCAL_CMD="./$SCRIPT -hostentry webhost $SERVER2_IP"
[[ $VERBOSE -eq 1 ]] && LOCAL_CMD="$LOCAL_CMD -verbose"
sudo $LOCAL_CMD
check_success "Local hostentry for webhost"

echo "All configurations applied successfully."


#!/bin/bash

# Ignore these signals so script won't stop if interrupted
trap "" TERM HUP INT

VERBOSE=0
DESIRED_NAME=""
DESIRED_IP=""
HOSTENTRY_NAME=""
HOSTENTRY_IP=""

# Print messages only if verbose mode is on
print_verbose() {
  if [ "$VERBOSE" -eq 1 ]; then
    echo "$1"
  fi
}

# Read command-line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -verbose)
      VERBOSE=1
      shift
      ;;
    -name)
      DESIRED_NAME="$2"
      shift 2
      ;;
    -ip)
      DESIRED_IP="$2"
      shift 2
      ;;
    -hostentry)
      HOSTENTRY_NAME="$2"
      HOSTENTRY_IP="$3"
      shift 3
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Change hostname if needed
if [ -n "$DESIRED_NAME" ]; then
  CURRENT_NAME=$(hostname)
  if [ "$CURRENT_NAME" != "$DESIRED_NAME" ]; then
    echo "$DESIRED_NAME" > /etc/hostname
    sed -i "s/$CURRENT_NAME/$DESIRED_NAME/g" /etc/hosts
    hostname "$DESIRED_NAME"
    logger "Hostname changed from $CURRENT_NAME to $DESIRED_NAME"
    print_verbose "Hostname changed from $CURRENT_NAME to $DESIRED_NAME."
  else
    print_verbose "Hostname is already $DESIRED_NAME."
  fi
fi

# Change IP address using Netplan
if [ -n "$DESIRED_IP" ]; then
  INTERFACE="eth0"  # Change this if needed
  CURRENT_IP=$(ip -4 addr show $INTERFACE | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

  if [ "$CURRENT_IP" != "$DESIRED_IP" ]; then
    if grep -q "$CURRENT_IP" /etc/hosts; then
      sed -i "s/$CURRENT_IP/$DESIRED_IP/g" /etc/hosts
    else
      echo "$DESIRED_IP $DESIRED_NAME" >> /etc/hosts
    fi

    NETPLAN_FILE=$(ls /etc/netplan/*.yaml | head -n 1)
    if [ -n "$NETPLAN_FILE" ]; then
      cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"

      # Use recommended default route format (avoids gateway4 warning)
      cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  ethernets:
    $INTERFACE:
      addresses: ["$DESIRED_IP/24"]
      routes:
        - to: 0.0.0.0/0
          via: 192.168.16.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
EOF

      netplan apply
      sleep 2

      # Confirm new IP address
      NEW_IP=$(ip -4 addr show $INTERFACE | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
      if [[ "$NEW_IP" == "$DESIRED_IP" ]]; then
        logger "IP successfully changed to $DESIRED_IP"
        print_verbose "IP address changed to $DESIRED_IP and confirmed."
      else
        echo "Error: Netplan did not apply IP change properly. Expected $DESIRED_IP, got $NEW_IP" >&2
      fi
    else
      echo "No netplan config found." >&2
    fi
  else
    print_verbose "IP address is already $DESIRED_IP."
  fi
fi

# Update /etc/hosts entry if needed
if [ -n "$HOSTENTRY_NAME" ] && [ -n "$HOSTENTRY_IP" ]; then
  if grep -q "^$HOSTENTRY_IP\s\+$HOSTENTRY_NAME" /etc/hosts; then
    print_verbose "Host entry $HOSTENTRY_NAME already in /etc/hosts."
  else
    sed -i "/\s$HOSTENTRY_NAME\s*$/d" /etc/hosts
    echo "$HOSTENTRY_IP $HOSTENTRY_NAME" >> /etc/hosts
    logger "/etc/hosts updated with $HOSTENTRY_IP $HOSTENTRY_NAME"
    print_verbose "/etc/hosts updated with $HOSTENTRY_IP $HOSTENTRY_NAME."
  fi
fi


#!/bin/bash

# This script configures server1 for COMP2137 Assignment 2.
# It sets the static IP, updates /etc/hosts, installs software,
# and creates users with SSH keys.

# Show message to user
print_message() {
  echo ""
  echo "========== $1 =========="
  echo ""
}

# STEP 1: Set the static IP address to 192.168.16.21
set_static_ip() {
  print_message "Setting static IP address"

  # Find the network interface connected to 192.168.16 network
  interface=$(ip -o -4 addr show | grep 192.168.16 | awk '{print $2}' | head -n1)

  # Find the netplan file
  netplan_file=$(grep -rl "192.168" /etc/netplan)

  # Check if IP is already set
  if grep -q "192.168.16.21" "$netplan_file"; then
    echo "Static IP is already set in netplan."
  else
    echo "Updating netplan file to set IP to 192.168.16.21..."
    sed -i "/$interface:/,/addresses:/ s/addresses:.*/addresses: [192.168.16.21\/24]/" "$netplan_file"
    netplan apply
    echo "Static IP address has been set."
  fi
}

# STEP 2: Update /etc/hosts file
update_hosts_file() {
  print_message "Updating /etc/hosts file"

  # Remove any old server1 lines and add the correct one
  sed -i '/server1/d' /etc/hosts
  echo "192.168.16.21 server1" >> /etc/hosts
  echo "/etc/hosts has been updated."
}

# STEP 3: Install apache2 and squid packages
install_software() {
  print_message "Installing apache2 and squid"

  apt-get update -qq

  # Install apache2 if not installed
  if ! dpkg -s apache2 &>/dev/null; then
    apt-get install -y apache2
    echo "apache2 installed."
  else
    echo "apache2 is already installed."
  fi

  # Install squid if not installed
  if ! dpkg -s squid &>/dev/null; then
    apt-get install -y squid
    echo "squid installed."
  else
    echo "squid is already installed."
  fi
}

# STEP 4: Create users and add SSH keys
create_users() {
  print_message "Creating users and setting up SSH keys"

  # List of users to create
  USERS=(dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda)

  # Extra SSH key for dennis
  EXTRA_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

  for user in "${USERS[@]}"; do
    echo "Checking user: $user"

    # Create user if not exists
    if ! id "$user" &>/dev/null; then
      useradd -m -s /bin/bash "$user"
      echo "User $user created."
    else
      echo "User $user already exists."
    fi

    SSH_DIR="/home/$user/.ssh"
    AUTH_KEYS="$SSH_DIR/authorized_keys"

    # Create .ssh and authorized_keys as the user
    sudo -u "$user" mkdir -p "$SSH_DIR"
    sudo -u "$user" touch "$AUTH_KEYS"

    # Create SSH keys if they don't exist
    if [ ! -f "$SSH_DIR/id_rsa.pub" ]; then
      sudo -u "$user" ssh-keygen -t rsa -N "" -f "$SSH_DIR/id_rsa" <<< y
      echo "RSA key created for $user"
    fi

    if [ ! -f "$SSH_DIR/id_ed25519.pub" ]; then
      sudo -u "$user" ssh-keygen -t ed25519 -N "" -f "$SSH_DIR/id_ed25519" <<< y
      echo "ED25519 key created for $user"
    fi

    # Add both keys to authorized_keys if not already there
    grep -qF "$(cat "$SSH_DIR/id_rsa.pub")" "$AUTH_KEYS" || cat "$SSH_DIR/id_rsa.pub" >> "$AUTH_KEYS"
    grep -qF "$(cat "$SSH_DIR/id_ed25519.pub")" "$AUTH_KEYS" || cat "$SSH_DIR/id_ed25519.pub" >> "$AUTH_KEYS"

    # For dennis, add the extra key and give sudo access
    if [ "$user" = "dennis" ]; then
      grep -qF "$EXTRA_KEY" "$AUTH_KEYS" || echo "$EXTRA_KEY" >> "$AUTH_KEYS"
      usermod -aG sudo dennis
      echo "Extra key added and sudo access granted to dennis"
    fi

    # Set correct permissions
    chown -R "$user:$user" "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chmod 600 "$AUTH_KEYS"
  done
}

# Run all steps in order
main() {
  print_message "Starting Assignment 2 Script"

  set_static_ip
  update_hosts_file
  install_software
  create_users

  print_message "All done! Server is now configured."
}

# Run the script
main


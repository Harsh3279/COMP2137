#!/bin/bash




iface=$(ip -o link show | awk -F': ' '{print $2}' | grep '^ens' | head -n1)
# grab interface and save to variable
ip a s "$iface" | grep -w inet | awk '{print $2}'
# print ip addr

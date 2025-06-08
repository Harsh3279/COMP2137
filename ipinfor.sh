#!/bin/bash

# grab interface....ens 33 and save it to variable
INTERFACE=$(ip r | grep default | cut -d' ' -f5)

# grab ip add of that interface and print
echo IPADDR=$(ip a show $INTERFACE | grep inet | head -n1 | tr -s ' ' | cut -d' ' -f3 | cut -d/ -f1)




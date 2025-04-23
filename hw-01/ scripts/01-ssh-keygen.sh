#!/bin/bash

ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

NODES=("192.168.1.83" "192.168.1.84" "192.168.1.85")

for node in "${NODES[@]}"; do
    scp ~/.ssh/authorized_keys team@$node:/home/team/.ssh/authorized_keys
done
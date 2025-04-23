#!/bin/bash
cat <<EOF | sudo tee -a /etc/hosts

192.168.1.82 team-20-jn
192.168.1.83 team-20-nn
192.168.1.84 team-20-dn-00
192.168.1.85 team-20-dn-01
EOF
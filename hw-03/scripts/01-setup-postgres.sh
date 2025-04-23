#!/bin/bash

sudo apt update
sudo apt install -y postgresql

# Настройка postgresql.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'team-20-nn'/" /etc/postgresql/16/main/postgresql.conf

# Настройка pg_hba.conf
echo "host    metastore       hive            192.168.1.1/32          password" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf
echo "host    metastore       hive            192.168.1.82/32         password" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

sudo systemctl restart postgresql

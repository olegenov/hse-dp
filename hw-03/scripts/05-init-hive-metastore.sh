#!/bin/bash

hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse

cd ~/apache-hive-4.0.0-alpha-2-bin
bin/schematool -dbType postgres -initSchema
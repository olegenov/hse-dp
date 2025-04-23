#!/bin/bash
cd /home/hadoop/hadoop-3.4.0


bin/hdfs namenode -format
sbin/start-dfs.sh
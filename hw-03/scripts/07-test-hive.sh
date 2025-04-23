#!/bin/bash

echo "id,name,age" > test_table.csv
echo "1,Alice,30" >> test_table.csv
echo "2,Bob,25" >> test_table.csv
echo "3,Charlie,35" >> test_table.csv

hdfs dfs -mkdir -p /test
hdfs dfs -put -f test_table.csv /test

beeline -u jdbc:hive2://team-20-jn:5433 -n scott -p tiger <<EOF
CREATE DATABASE IF NOT EXISTS test;
CREATE TABLE IF NOT EXISTS test.people (id int, name string, age int)
COMMENT 'people_table'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t';
LOAD DATA INPATH '/test/test_table.csv' INTO TABLE test.people;
EOF
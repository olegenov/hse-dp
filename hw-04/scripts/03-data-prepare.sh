#!/bin/bash

wget https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv
hdfs dfs -mkdir /input
hdfs dfs -put titanic.csv /input/
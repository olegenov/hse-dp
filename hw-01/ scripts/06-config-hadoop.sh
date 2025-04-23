#!/bin/bash
HADOOP_CONF_DIR=/home/hadoop/hadoop-3.4.0/etc/hadoop

echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HADOOP_CONF_DIR/hadoop-env.sh

cat <<EOF > $HADOOP_CONF_DIR/core-site.xml
<configuration>
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://team-20-nn:9000</value>
</property>
</configuration>
EOF

cat <<EOF > $HADOOP_CONF_DIR/hdfs-site.xml
<configuration>
<property>
  <name>dfs.replication</name>
  <value>3</value>
</property>
</configuration>
EOF

cat <<EOF > $HADOOP_CONF_DIR/workers
team-20-nn
team-20-dn-00
team-20-dn-01
EOF

CONF_DIR=/home/hadoop/hadoop-3.4.0/etc/hadoop
NODES=("team-20-dn-00" "team-20-dn-01")

for node in "${NODES[@]}"; do
    scp $CONF_DIR/hadoop-env.sh hadoop@$node:$CONF_DIR/
    scp $CONF_DIR/core-site.xml hadoop@$node:$CONF_DIR/
    scp $CONF_DIR/hdfs-site.xml hadoop@$node:$CONF_DIR/
    scp $CONF_DIR/workers hadoop@$node:$CONF_DIR/
done
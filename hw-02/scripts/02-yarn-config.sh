#!/bin/bash

sudo -i -u hadoop <<'EOF'

cat <<EOL > ~/hadoop-3.4.0/etc/hadoop/yarn-site.xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelists</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>team-20-nn</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>team-20-nn:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>team-20-nn:8031</value>
    </property>
</configuration>
EOL

cat <<EOL > ~/hadoop-3.4.0/etc/hadoop/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>\$HADOOP_HOME/share/hadoop/mapreduce/*:\$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOL

for host in team-20-nn team-20-dn-00 team-20-dn-01; do
    scp ~/hadoop-3.4.0/etc/hadoop/yarn-site.xml hadoop@$host:~/hadoop-3.4.0/etc/hadoop/
    scp ~/hadoop-3.4.0/etc/hadoop/mapred-site.xml hadoop@$host:~/hadoop-3.4.0/etc/hadoop/
done

EOF

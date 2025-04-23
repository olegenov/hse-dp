#!/bin/bash

wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
cd apache-hive-4.0.0-alpha-2-bin/lib/
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar

cat > ~/apache-hive-4.0.0-alpha-2-bin/conf/hive-site.xml <<EOF
<configuration>
        <property>
                <name>hive.server2.authentication</name>
                <value>NONE</value>
        </property>
        <property>
                <name>hive.metastore.warehouse.dir</name>
                <value>/user/hive/warehouse</value>
        </property>
        <property>
                <name>hive.server2.thrift.port</name>
                <value>5433</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionURL</name>
                <value>jdbc:postgresql://team-20-nn:5432/metastore</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionDriverName</name>
                <value>org.postgresql.Driver</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionUserName</name>
                <value>hive</value>
        </property>
        <property>
                <name>javax.jdo.option.ConnectionPassword</name>
                <value>hiveUltraPass</value>
        </property>
</configuration>
EOF

echo "export HIVE_HOME=\$HOME/apache-hive-4.0.0-alpha-2-bin" >> ~/.profile
echo "export HIVE_CONF_DIR=\$HIVE_HOME/conf" >> ~/.profile
echo "export HIVE_AUX_JARS_PATH=\$HIVE_HOME/lib/*" >> ~/.profile
echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> ~/.profile
source ~/.profile
# HW-03

узел для входа 176.109.91.22

```
192.168.1.82 team-20-jn
192.168.1.83 team-20-nn
192.168.1.84 team-20-dn-00
192.168.1.85 team-20-dn-01
```

Развертывание Apache Hive таким образом, чтобы была возможность одновременного его использования более чем одним клиентом.

## Подготовка
Подразумевается, что все сервисы предыдущих этапов к данному этапу запущены и исправно функционируют

> На team-20-nn от пользователя team
```
01-setup-postgres.sh
```

>На team-20-nn от пользователя postgres
```
02-init-metastore.sql
```

>На team-20-jn от пользователя team
```
03-install-pg-client.sh
```

**Подробнее:**

### Установка и инициализация PostgreSQL
С пользователя team на nn выполяем:
```sh
sudo apt install postgresql
```

Переключение на пользователя postgres
```sh
sudo -i -u postgres
```
```sh
psql
```

Создание БД:
```sql
CREATE DATABASE metastore;
```

Создание пользователя БД:
```sql
CREATE USER hive with password 'hiveUltraPass';
GRANT ALL PRIVILEGES ON DATABASE "metastore" to hive;
ALTER DATABASE metastore OWNER TO hive;
```

Ограничиваем права доступа,
с пользователя team на nn дополняем ```/etc/postgresql/16/main/postgresql.conf```:
```conf
listen_addresses = 'team-20-nn'
```

Дополняем файл ```/etc/postgresql/16/main/pg_hba.conf```:
```conf
host    metastore       hive            192.168.1.1/32          password
host    metastore       hive            192.168.1.82/32         password # jn ip
```

Перезагружаем postgresql:
```sh
sudo systemctl restart postgresql
```

### Установка клиента postgreSQL
С пользователя team на jn выполняем:
```sh
sudo apt install postgresql-client-16
```

### Установка Hive
С пользователя hadoop на jn выполняем:
```sh
wget https://archive.apache.org/dist/hive/hive-4.0.0-alpha-2/apache-hive-4.0.0-alpha-2-bin.tar.gz
tar -xzvf apache-hive-4.0.0-alpha-2-bin.tar.gz
cd apache-hive-4.0.0-alpha-2-bin/lib/
wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
```

## Настройка Hive

>На team-20-jn от пользователя hadoop
```
04-install-and-configure-hive.sh
05-init-hive-metastore.sh
```

**Подробнее:**

### Конфигурация

Создать файл ```~/apache-hive-4.0.0-alpha-2-bin/conf/hive-site.xml```:
```xml
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
                <description>TCP port number to listen on, default 10000</description>
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

```

Добавляем переменные окружения в ```.profile```:
```sh
export HIVE_HOME=/home/hadoop/apache-hive-4.0.0-alpha-2-bin
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin
```
```sh
source ~/.profile
```

### Настройка БД

Создание директории для данных:
```sh
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
```

Инициализация БД в ```apache-hive-4.0.0-alpha-2-bin/```:
```sh
bin/schematool -dbType postgres -initSchema
```

## Запуск Hive

>На team-20-jn от пользователя hadoop
```
06-start-hive.sh
```

**Подробнее:**

С пользователя hadoop на jn выполяем:
В ```apache-hive-4.0.0-alpha-2-bin/``` выполняем:
```sh
hive --service hiveserver2 --hiveconf hive.server2.enable.doAs=false --hiveconf hive.security.authorization.enable=false < /dev/null 1>> /tmp/hs2.log 2>> /tmp/hs2.log &
```

## Подключение
С пользователя hadoop на jn выполяем:
```sh
beeline -u jdbc:hive2://team-20-jn:5433 -n scott -p tiger
```

## Проверка

>На team-20-jn от пользователя hadoop
```
07-test-hive.sh
```

**Подробнее:**

### Создание данных
С пользователя hadoop на jn выполяем:
```sh
touch test_table.csv
echo "id,name,age" > test_table.csv
echo "1,Alice,30" >> test_table.csv
echo "2,Bob,25" >> test_table.csv
echo "3,Charlie,35" >> test_table.csv
hdfs dfs -mkdir -p /test
hdfs dfs -put -f test_table.csv /test
```

### Подключение
```sh
beeline -u jdbc:hive2://team-20-jn:5433 -n scott -p tiger
```

### Создание тестовой БД
```sql
CREATE DATABASE test;
CREATE TABLE IF NOT EXISTS test.people (id int, name string, age int) COMMENT 'people_table' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';
```

### Загрузка данных в БД
```sql
LOAD DATA INPATH '/test/test_table.csv' INTO TABLE test.people;
```
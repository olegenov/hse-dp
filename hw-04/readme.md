# HW-04

узел для входа 176.109.91.22

```
192.168.1.82 team-20-jn
192.168.1.83 team-20-nn
192.168.1.84 team-20-dn-00
192.168.1.85 team-20-dn-01
```

Использование Apache Spark под управлением YARN
для чтения, трансформации и записи данных.

## Подготовка
Подразумевается, что все сервисы предыдущих этапов к данному этапу запущены и исправно функционируют

>team@team-20-jn
```sh
01-download-libs.sh
```

>hadoop@team-20-jn
```sh
02-setup-spark.sh
03-data-prepare.sh
```

**Подробнее:**

### Установка библиотек
team@team-20-jn
```sh
sudo apt install python3-venv
sudo apt install python3-pip
```

### Скачивание и настройка Spark
hadoop@team-20-jn:

Скачиваем архив и распаковываем:
```sh
wget https://archive.apache.org/dist/spark/spark-3.5.3/spark-3.5.3-bin-hadoop3.tgz
tar -xzvf spark-3.5.3-bin-hadoop3.tgz
```

Объявляем переменные:
```sh
export HADOOP_CONF_DIR="/home/hadoop/hadoop-3.4.0/etc/hadoop"
export HIVE_HOME="/home/hadoop/apache-hive-4.0.0-alpha-2-bin"
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib/*
export PATH=$PATH:$HIVE_HOME/bin

export SPARK_LOCAL_IP=192.168.1.82
export SPARK_DIST_CLASSPATH="/home/hadoop/spark-3.5.3-bin-hadoop3/jars/*:/home/hadoop/hadoop-3.4.0/etc/hadoop:/home/hadoop/hadoop-3.4.0/share/hadoop/common/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/common/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/hdfs/*:/home/hadoop/hadoop-3.4.0/share/hadoop/mapreduce/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/lib/*:/home/hadoop/hadoop-3.4.0/share/hadoop/yarn/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/*:/home/hadoop/apache-hive-4.0.0-alpha-2-bin/lib/*"

cd spark-3.5.3-bin-hadoop3/
export SPARK_HOME=`pwd`

export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH

export PATH=$SPARK_HOME/bin:$PATH

cd ../
```

Создаем виртуальное окружение:
```sh
python3 -m venv venv
source venv/bin/activate
```

Настраиваем виртуальное окружение:
```sh
pip install -U pip
pip install ipython
pip install onetl[files]
```

### Подготовка данных

```sh
wget https://raw.githubusercontent.com/datasciencedojo/datasets/master/titanic.csv
hdfs dfs -mkdir /input
hdfs dfs -put titanic.csv /input/
```

## Запуск Spark

```sh
nohup hive --service metastore > metastore.log 2>&1 &
ipython
```

>hadoop@team-20-jn
```sh
04-spark-setup.py
```

**Подробнее:**

### Запуск
```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from onetl.connection import SparkHDFS
from onetl.connection import Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter

spark = SparkSession.builder.master("yarn").appName("spark-with-yarn").config("spark.sql.warehouse.dir", "/user/hive/warehouse").config("spark.hive.metastore.uris", "thrift://team-20-jn:9083").enableHiveSupport().getOrCreate()
```

### Загрузка данных

```python
hdfs = SparkHDFS(host="team-20-nn", port=9000, spark=spark, cluster="test")
reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
df = reader.run(["titanic.csv"])

df.count() # Out[14]: 891
df.printSchema()
# root
#  |-- PassengerId: string (nullable = true)
#  |-- Survived: string (nullable = true)
#  |-- Pclass: string (nullable = true)
#  |-- Name: string (nullable = true)
#  |-- Sex: string (nullable = true)
#  |-- Age: string (nullable = true)
#  |-- SibSp: string (nullable = true)
#  |-- Parch: string (nullable = true)
#  |-- Ticket: string (nullable = true)
#  |-- Fare: string (nullable = true)
#  |-- Cabin: string (nullable = true)
#  |-- Embarked: string (nullable = true)
```

### Запись данных

```python
hive = Hive(spark=spark, cluster="test")
writer = DBWriter(connection=hive, table="test.spark_partitions", options={"if_exists": "replace_entire_table"})
writer.run(df)
```

## Использование

>hadoop@team-20-jn
```sh
05-inner-test.sh
06-test-by-hive.sh
```

### Трансформация данных
Приведение типов, фильтрация, создание новых колонок, агрегации:
```python
from pyspark.sql.types import IntegerType, DoubleType

df_transformed = (
    df.withColumn("Age", F.col("Age").cast(DoubleType()))
      .withColumn("Fare", F.col("Fare").cast(DoubleType()))
      .withColumn("Survived", F.col("Survived").cast(IntegerType()))
      .filter(F.col("Age").isNotNull())
      .withColumn("AgeGroup", F.when(F.col("Age") < 18, "Child")
                               .when(F.col("Age") < 60, "Adult")
                               .otherwise("Senior"))
)
```

### Партиционирование и сохранение

Партиционируем по Pclass:

```python
writer = DBWriter(
    connection=hive,
    table="test.titanic_partitioned",
    options={
        "if_exists": "replace_entire_table",
        "partition_by": ["Pclass"]
    }
)

writer.run(df_transformed)
```

Видим результат партиций:
```sh
$ hdfs dfs -ls /user/hive/warehouse/test.db/titanic_partitioned/
Found 4 items
drwxr-xr-x   - hadoop supergroup          0 2025-04-24 20:57 /user/hive/warehouse/test.db/titanic_partitioned/Pclass=1
drwxr-xr-x   - hadoop supergroup          0 2025-04-24 20:57 /user/hive/warehouse/test.db/titanic_partitioned/Pclass=2
drwxr-xr-x   - hadoop supergroup          0 2025-04-24 20:57 /user/hive/warehouse/test.db/titanic_partitioned/Pclass=3
-rw-r--r--   3 hadoop supergroup          0 2025-04-24 20:57 /user/hive/warehouse/test.db/titanic_partitioned/_SUCCESS
```

```
In [32]: spark.sql("""
    ...:     SELECT Sex, COUNT(*) as count
    ...:     FROM test.titanic_partitioned
    ...:     WHERE Pclass = '1'
    ...:     GROUP BY Sex
    ...: """).show()
+------+-----+                                                                  
|   Sex|count|
+------+-----+
|female|   85|
|  male|  101|
+------+-----+
```

### Чтение клиентом Hive
hadoop@team-20-jn:
```sh
beeline -u jdbc:hive2://team-20-jn:5433 -n scott -p tiger
```

```sql
USE test;
SHOW TABLES;
SELECT COUNT(*) FROM titanic_partitioned;
```
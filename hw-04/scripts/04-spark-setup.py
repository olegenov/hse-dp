from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType, DoubleType
from onetl.connection import SparkHDFS, Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter

# Запуск Spark
spark = SparkSession.builder \
    .master("yarn") \
    .appName("spark-with-yarn") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("spark.hive.metastore.uris", "thrift://team-20-jn:9083") \
    .enableHiveSupport() \
    .getOrCreate()

# Чтение данных
hdfs = SparkHDFS(host="team-20-nn", port=9000, spark=spark, cluster="test")
reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
df = reader.run(["titanic.csv"])

# Трансформация
df_transformed = (
    df.withColumn("Age", F.col("Age").cast(DoubleType()))
      .withColumn("Fare", F.col("Fare").cast(DoubleType()))
      .withColumn("Survived", F.col("Survived").cast(IntegerType()))
      .filter(F.col("Age").isNotNull())
      .withColumn("AgeGroup", F.when(F.col("Age") < 18, "Child")
                               .when(F.col("Age") < 60, "Adult")
                               .otherwise("Senior"))
)

# Запись в Hive с партиционированием
hive = Hive(spark=spark, cluster="test")
writer = DBWriter(
    connection=hive,
    table="test.titanic_partitioned",
    options={"if_exists": "replace_entire_table", "partition_by": ["Pclass"]}
)
writer.run(df_transformed)
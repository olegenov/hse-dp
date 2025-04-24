from pyspark.sql import SparkSession
from pyspark.sql.types import IntegerType, DoubleType
from onetl.connection import SparkHDFS, Hive
from onetl.file import FileDFReader
from onetl.file.format import CSV
from onetl.db import DBWriter
from pyspark.sql import functions as F
from prefect import flow, task


@task
def get_spark():
    spark = SparkSession.builder \
        .master("yarn") \
        .appName("spark-with-yarn") \
        .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
        .config("spark.hive.metastore.uris", "thrift://team-20-jn:9083") \
        .enableHiveSupport() \
        .getOrCreate()
    
    return spark


@task
def stop_spark(spark):
    spark.stop()


@task
def extract(spark):
    hdfs = SparkHDFS(host="team-20-nn", port=9000, spark=spark, cluster="test")
    reader = FileDFReader(connection=hdfs, format=CSV(delimiter=",", header=True), source_path="/input")
    df = reader.run(["titanic.csv"])

    return df

@task
def transform(df):
    df_transformed = (
        df.withColumn("Age", F.col("Age").cast(DoubleType()))
        .withColumn("Fare", F.col("Fare").cast(DoubleType()))
        .withColumn("Survived", F.col("Survived").cast(IntegerType()))
        .filter(F.col("Age").isNotNull())
        .withColumn("AgeGroup", F.when(F.col("Age") < 18, "Child")
                                .when(F.col("Age") < 60, "Adult")
                                .otherwise("Senior"))
    )

    return df_transformed


@task
def load(spark, df):
    hive = Hive(spark=spark, cluster="test")
    writer = DBWriter(
        connection=hive,
        table="test.titanic_partitioned",
        options={"if_exists": "replace_entire_table", "partition_by": ["Pclass"]}
    )
    writer.run(df)


@flow
def process_data():
    spark = get_spark()
    df = extract(spark)
    df = transform(df)
    load(spark, df)
    stop_spark(spark)


if __name__ == "__main__":
    process_data()
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

writer = DBWriter(
    connection=hive,
    table="test.titanic_partitioned",
    options={
        "if_exists": "replace_entire_table",
        "partition_by": ["Pclass"]
    }
)

writer.run(df_transformed)
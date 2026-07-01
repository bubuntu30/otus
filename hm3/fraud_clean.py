from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length, input_file_name

spark = SparkSession.builder.appName("fraud-clean").getOrCreate()

input_path = "s3a://otus-fraud-suv/raw/*"
output_path = "s3a://otus-fraud-suv/clean/"

df = spark.read.text(input_path)

df = df.withColumn("len", length("value"))
df = df.withColumn("file", input_file_name())

print("RAW:", df.count())

clean_df = df \
    .filter(col("value").isNotNull()) \
    .filter(length("value") > 0) \
    .filter(length("value") >= 20) \
    .filter(length("value") <= 5000) \
    .dropDuplicates(["value"])

print("CLEAN:", clean_df.count())
clean_df.write \
    .mode("overwrite") \
    .parquet(output_path)

print("Saved to:", output_path)

spark.stop()
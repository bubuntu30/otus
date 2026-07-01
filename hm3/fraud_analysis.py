from pyspark.sql import SparkSession
from pyspark.sql.functions import col, length, input_file_name, avg

spark = SparkSession.builder \
    .appName("fraud-analysis") \
    .config("spark.sql.shuffle.partitions", "20") \
    .config("spark.sql.adaptive.enabled", "true") \
    .getOrCreate()

df = spark.read.text(
    "s3a://otus-fraud-suv/raw/2019-08-22.txt"
)
df = df.withColumn("len", length("value"))
df = df.withColumn("file", input_file_name())

df.cache()
total = df.count()

nulls = df.filter(col("value").isNull()).count()
short = df.filter(col("len") < 20).count()
long = df.filter(col("len") > 5000).count()
print("nulls:", nulls)
print("short:", short)
print("long:", long)
print("missing_ratio:", nulls / total if total > 0 else 0)

unique = df.select("value").distinct().count()
duplicates = total - unique
print("duplicates:", duplicates)
df.groupBy("len").count().orderBy("len").show(20)
mean_len = df.select(avg("len")).collect()[0][0]

outliers = df.filter(
    (col("len") > mean_len * 3) | (col("len") < mean_len * 0.3)
)
print("outliers:", outliers.count())
df.groupBy("file").avg("len").orderBy("file").show(100, False)

spark.stop()
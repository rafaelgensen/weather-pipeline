from pyspark.sql import SparkSession
from pyspark.sql.functions import col, when

if __name__ == "__main__":
    spark = SparkSession.builder.appName("TransformWeather").getOrCreate()

    # buckets já definidos
    s3_input_path = "s3://weather-raw-663354324751"
    s3_output_path = "s3://weather-processed-663354324751"

    # Lê parquet bruto
    df = spark.read.parquet(s3_input_path)

    # Transforma
    df_transformed = df.withColumn(
        "rain_expected",
        when(col("weather") == "Rain", True).otherwise(False)
    )

    # Grava processado
    df_transformed.write.mode("overwrite").parquet(s3_output_path)

    spark.stop()
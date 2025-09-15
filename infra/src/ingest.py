import os
import requests
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, LongType

if __name__ == "__main__":
    spark = SparkSession.builder.appName("IngestWeather").getOrCreate()

    s3_output_path = "s3://weather-raw-663354324751"
    api_key = os.getenv("api_key_weather")
    city = "London"

    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"
    response = requests.get(url)
    data = response.json()

    # DEBUG: print raw API response for troubleshooting
    print("API response:", data)

    # Ensure expected fields are present
    if "main" not in data or "weather" not in data or not data.get("weather"):
        raise ValueError(f"Unexpected API response: {data}")

    record = {
        "city": data.get("name"),
        "temp": float(data["main"].get("temp")),
        "humidity": float(data["main"].get("humidity")),
        "weather": data["weather"][0].get("main"),
        "timestamp": int(data.get("dt"))
    }

    schema = StructType([
        StructField("city", StringType(), True),
        StructField("temp", DoubleType(), True),
        StructField("humidity", DoubleType(), True),
        StructField("weather", StringType(), True),
        StructField("timestamp", LongType(), True)
    ])

    df = spark.createDataFrame([record], schema=schema)

    output_path = f"{s3_output_path}/date={record['timestamp']}"
    df.write.mode("overwrite").parquet(output_path)

    spark.stop()
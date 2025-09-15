resource "aws_glue_crawler" "processed" {
  name          = "weather-processed-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.weather_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.processed.bucket}/"
  }
}
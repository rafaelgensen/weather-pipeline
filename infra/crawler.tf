# Glue Crawler - Processed
resource "aws_glue_crawler" "processed" {
  name          = "weather-processed-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.weather_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.processed.bucket}/"
  }

  # Evita criar se já existir (apenas Terraform importará)
  depends_on = [aws_iam_role_policy_attachment.glue_s3]
}
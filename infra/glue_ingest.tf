# Upload ingest.py script to S3 for Glue Job
resource "aws_s3_object" "ingest_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "ingest.py"
  source = "src/ingest.py"
}

# Glue Job for API ingestion
resource "aws_glue_job" "ingest" {
  name     = "weather-ingest-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/ingest.py"
  }

  default_arguments = {
    "--TempDir" = "s3://${aws_s3_bucket.backend.bucket}/tmp/"
    "--API_KEY" = var.api_key_weather  # Pass API key as environment variable to Glue
  }

  max_retries = 0

  depends_on = [aws_s3_object.ingest_script]
}
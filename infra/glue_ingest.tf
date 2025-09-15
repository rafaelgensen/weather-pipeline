# Upload ingest.py script to S3 for Glue Job
resource "aws_s3_object" "ingest_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "ingest.py"
  source = "src/ingest.py"
}

# AWS Glue Job for OpenWeather API ingestion
resource "aws_glue_job" "ingest" {
  name     = "weather-ingest-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/ingest.py"
  }

  default_arguments = {
    "--TempDir"          = "s3://${aws_s3_bucket.backend.bucket}/tmp/"
    "--api_key_weather"  = var.api_key_weather  # Must match the os.getenv key in Python
    "--job-language"     = "python"
  }

  glue_version = "4.0"
  max_retries  = 0

  depends_on = [aws_s3_object.ingest_script]
}
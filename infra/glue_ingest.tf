# Upload the local ingest.py script to the Glue scripts bucket in S3
resource "aws_s3_object" "ingest_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "ingest.py"
  source = "src/ingest.py"               # Local path to the script
  etag   = filemd5("src/ingest.py")      # Ensure changes are detected by Terraform
}

# AWS Glue Job to ingest data from OpenWeather API and store in S3
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
  }

  max_retries = 0

  # Ensure script is uploaded before the job is created
  depends_on = [aws_s3_object.ingest_script]
}
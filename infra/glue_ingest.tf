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
}
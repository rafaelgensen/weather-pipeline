# Upload the local transform.py script to the Glue scripts bucket in S3
resource "aws_s3_object" "transform_script" {
  bucket = aws_s3_bucket.glue_scripts.bucket
  key    = "transform.py"
  source = "src/transform.py"
}

# AWS Glue Job to transform weather data and write to the processed S3 bucket
resource "aws_glue_job" "transform" {
  name     = "weather-transform-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/transform.py"
  }

  default_arguments = {
    "--TempDir" = "s3://${aws_s3_bucket.backend.bucket}/tmp/"
  }

  max_retries = 0

  # Ensure script is uploaded before the job is created
  depends_on = [aws_s3_object.transform_script]
}
# Buckets
resource "aws_s3_bucket" "backend" {
  bucket = "weather-states-663354324751"
}

resource "aws_s3_bucket" "raw" {
  bucket = "weather-raw-663354324751"
}

resource "aws_s3_bucket" "processed" {
  bucket = "weather-processed-663354324751"
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "weather-glue-scripts-663354324751"
}

# IAM Role para Glue
resource "aws_iam_role" "glue_role" {
  name = "factored-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = { Service = "glue.amazonaws.com" }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Glue Service Role policy removida (não existe attachable)
# resource "aws_iam_role_policy_attachment" "glue_catalog" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSGlueServiceRole"
# }

# Bucket Policies corretas
data "aws_iam_policy_document" "glue_bucket_access" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.backend.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.backend.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.raw.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.raw.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.processed.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.processed.bucket}/*",
      "arn:aws:s3:::${aws_s3_bucket.glue_scripts.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.glue_scripts.bucket}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "glue_access_backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.glue_bucket_access.json
}

resource "aws_s3_bucket_policy" "glue_access_raw" {
  bucket = aws_s3_bucket.raw.id
  policy = data.aws_iam_policy_document.glue_bucket_access.json
}

resource "aws_s3_bucket_policy" "glue_access_processed" {
  bucket = aws_s3_bucket.processed.id
  policy = data.aws_iam_policy_document.glue_bucket_access.json
}

resource "aws_s3_bucket_policy" "glue_access_scripts" {
  bucket = aws_s3_bucket.glue_scripts.id
  policy = data.aws_iam_policy_document.glue_bucket_access.json
}
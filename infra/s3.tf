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
      aws_s3_bucket.backend.arn,
      "${aws_s3_bucket.backend.arn}/*",
      aws_s3_bucket.raw.arn,
      "${aws_s3_bucket.raw.arn}/*",
      aws_s3_bucket.processed.arn,
      "${aws_s3_bucket.processed.arn}/*",
      aws_s3_bucket.glue_scripts.arn,
      "${aws_s3_bucket.glue_scripts.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "glue_access" {
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
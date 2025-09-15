resource "aws_iam_role" "step_function_role" {
  name = "weather-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_policy" {
  name = "weather-step-function-policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:GetJob"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "glue:StartCrawler"
        ],
        Resource = aws_glue_crawler.processed.arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "weather_pipeline" {
  name     = "weather-pipeline"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "State machine to orchestrate weather data processing"
    StartAt = "IngestJob"
    States = {
      IngestJob = {
        Type     = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = aws_glue_job.ingest.name
        },
        Next = "TransformJob"
      },
      TransformJob = {
        Type     = "Task",
        Resource = "arn:aws:states:::glue:startJobRun.sync",
        Parameters = {
          JobName = aws_glue_job.transform.name
        },
        Next = "RunCrawler"
      },
      RunCrawler = {
        Type     = "Task",
        Resource = "arn:aws:states:::aws-sdk:glue:startCrawler",
        Parameters = {
          Name = aws_glue_crawler.processed.name
        },
        End = true
      }
    }
  })
}
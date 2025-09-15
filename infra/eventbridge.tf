resource "aws_cloudwatch_event_rule" "weekly_trigger" {
  name                = "weather-weekly-trigger"
  description         = "Dispara a execução da Step Function toda segunda-feira às 12:00 UTC"
  schedule_expression = "cron(0 12 ? * MON *)"
}

resource "aws_cloudwatch_event_target" "trigger_state_machine" {
  rule      = aws_cloudwatch_event_rule.weekly_trigger.name
  target_id = "weather-state-machine"
  arn       = aws_sfn_state_machine.weather_pipeline.arn
  role_arn  = aws_iam_role.eventbridge_invoke_role.arn
}

resource "aws_iam_role" "eventbridge_invoke_role" {
  name = "eventbridge-invoke-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_policy" {
  name = "eventbridge-invoke-policy"
  role = aws_iam_role.eventbridge_invoke_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "states:StartExecution",
        Resource = aws_sfn_state_machine.weather_pipeline.arn
      }
    ]
  })
}
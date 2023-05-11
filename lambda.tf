# IAM Role
resource "aws_iam_role" "iam_for_lambda" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = var.tags
}

# IAM policy document
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "CreateLogGroup"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    sid       = "CreateAndPutLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lamdba/${var.lambda_function_name}:*"]
  }

  statement {
    sid       = "SgDescribe"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }

}

# IAM policy
resource "aws_iam_policy" "lambda_iam_role_policy" {
  name        = var.iam_policy_name
  description = var.iam_policy_description
  policy      = data.aws_iam_policy_document.policy.json
  tags        = var.tags
}

# IAM policy attachment to role
resource "aws_iam_policy_attachment" "lambda_iam_role_policy-attach" {
  name       = "lambda_security_group_policy_attach"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.lambda_iam_role_policy.arn
}

# Zip the lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = var.lambda_zip
}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = var.lambda_function_handler
  runtime          = var.lambda_function_runtime
  timeout          = var.lambda_function_timeout
  source_code_hash = base64sha256(var.lambda_zip)
  environment {
    variables = {
      sns_topic   = var.lambda_variable_sns_topic
      sns_subject = var.lambda_variable_sns_subject
    }
  }
  tags = var.tags
}

# CloudWatch event rule
resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = var.event_rule_name
  description = var.event_rule_description
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName   = ["AuthorizeSecurityGroupIngress"]
    }
  })
  tags = var.tags
}

# CloudWatch event target
resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = var.lambda_function_name
  arn       = aws_lambda_function.lambda_function.arn
}

# Lambda permission
resource "aws_lambda_permission" "allow_cloudwatch_to_call_scheduler" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

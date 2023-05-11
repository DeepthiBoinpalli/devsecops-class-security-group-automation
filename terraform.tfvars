region = "us-east-1"
# Lambda
lambda_source_file          = "lambda/security-group-validator.py"
lambda_zip                  = "lambda/security-group-validator.zip"
lambda_function_name        = "security-group-validator"
lambda_function_handler     = "security-group-validator.lambda_handler"
lambda_function_runtime     = "python3.9"
lambda_function_timeout     = "300"
lambda_variable_sns_topic   = "arn:aws:sns:us-east-1:479379427248:partha-sns"
lambda_variable_sns_subject = "Security Group Compliance notification"
# Eventbridge
event_rule_name        = "security-group-validator"
event_rule_description = "Security group Compliance"
# IAM
iam_role_name          = "lambda-role-security-group-compliance"
iam_policy_name        = "lambda-policy-security-group-compliance"
iam_policy_description = "Lambda policy for Security group compliance"
#tags
tags = {
  owner       = "DevOps Team"
  cost-center = "xyz-123-b"
  automation  = "terraform"
}
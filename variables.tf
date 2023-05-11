variable "region" {
  type = string
}

variable "lambda_source_file" {
  type = string
}

variable "lambda_zip" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_function_handler" {
  type = string
}

variable "lambda_function_runtime" {
  type = string
}

variable "lambda_function_timeout" {
  type = string
}

variable "event_rule_name" {
  type = string
}

variable "event_rule_description" {
  type = string
}

variable "iam_policy_name" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "iam_policy_description" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign"
  default     = {}
  type        = map(string)
}

variable "lambda_variable_sns_topic" {
  type = string
}

variable "lambda_variable_sns_subject" {
  type = string
}
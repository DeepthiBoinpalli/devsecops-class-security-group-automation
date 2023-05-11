data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

## Provider
provider "aws" {
  region = var.region
}

## Terraform version
terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5"
    }
  }
}

## Terraform state backend
terraform {
  backend "s3" {
  }
}

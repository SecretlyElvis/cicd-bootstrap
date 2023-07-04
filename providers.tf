terraform {
  
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      version = "~> 4.0"
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = var.bucket
    key            = var.key
    dynamodb_table = var.dynamodb_table
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# In this branch I'm testing whether direct AWS config (rather than assuming role) will work
#  assume_role {
#    role_arn     = var.role_arn
#    session_name = "SESSION_NAME"
#    external_id  = "EXTERNAL_ID"
#  }
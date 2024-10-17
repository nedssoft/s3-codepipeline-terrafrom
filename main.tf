terraform {

# uncomment this if you want to use a backend
# backend "s3" {
#     bucket = "project-name-terraform-state-bucket"
#     key    = "terraform.tfstate"
#     region = "eu-west-2"
#     dynamodb_table =  "project-name-terraform-state-lock"
#     encrypt = true
#   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2" # change this to your region

  # use this if you want to use a profile
  # profile = "profile-name"

  # use this if you are not using a profile
  access_key = "AWS_ACCESS_KEY"
  secret_key = "AWS_SECRET_KEY"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  env = terraform.workspace
  base_name = format("%s-%s",var.project_name, terraform.workspace)
  account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
}

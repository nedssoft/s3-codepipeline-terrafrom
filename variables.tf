variable "project_name" {
  type = string
  description = "The name of the project"
}

variable "domain_name" {
  type = string
  description = "The domain name to use for the website e.g. example.com"
}

variable "hosted_zone_id" {
  type = string
  description = "The hosted zone ID for the domain"
}

variable "acm_certificate_arn" {
  type = string
  description = "The ARN of an existing ACM certificate in us-east-1"
}

variable "build_image" {
  type = string
  default = "aws/codebuild/standard:7.0"
}

variable "codebuild_env" {
  type = map(string)
  default = {
    "PROJECT_NAME" = "project_name"
    "ENVIRONMENT" = "dev"
  }
}

variable "branch_name" {
  type = string
  description = "The name of the branch to use for the website e.g. dev"
}

variable "repository_url" {
  type = string
  description = "The URL of the repository to use for the website e.g. https://github.com/github_username/repository_name.git"
}

variable "repository_id" {
  type = string
  description = "The ID of the repository to use for the website e.g. github_username/repository_name"
}
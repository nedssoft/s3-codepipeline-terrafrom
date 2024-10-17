resource "aws_s3_bucket" "build_artifacts" {
  bucket = "${local.base_name}-build-artifacts"
  force_destroy = true
}

# Uncomment to enable cloudwatch logging
# resource "aws_cloudwatch_log_group" "codebuild_log_group" {
#   name = "${local.base_name}-codebuild-log-group"
# }

# Uncomment to enable cloudwatch logging
# resource "aws_cloudwatch_log_stream" "codebuild_log_stream" {
#   name           = "${local.base_name}-codebuild-log-stream"
#   log_group_name = aws_cloudwatch_log_group.codebuild_log_group.name
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "build_role" {
  name               = "${local.base_name}-build-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "coldbuild_policy" {

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.build_artifacts.arn,
      "${aws_s3_bucket.build_artifacts.arn}/*",
      aws_s3_bucket.pipeline_artifacts.arn,
      "${aws_s3_bucket.pipeline_artifacts.arn}/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "coldbuild_policy" {
  role   = aws_iam_role.build_role.name
  policy = data.aws_iam_policy_document.coldbuild_policy.json
}

resource "aws_codebuild_project" "build_project" {
  name          = "${local.base_name}-build-project"
  description   = "${local.base_name} build project"
  build_timeout = 5
  service_role  = aws_iam_role.build_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.build_artifacts.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.codebuild_env
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

  }

  logs_config {
    cloudwatch_logs {
      status   = "DISABLED"
      # Uncomment if cloudwatch logging is enabled
      # group_name  = aws_cloudwatch_log_group.codebuild_log_group.name
      # stream_name = aws_cloudwatch_log_stream.codebuild_log_stream.name
    }

    s3_logs {
      status   = "DISABLED"
      # Uncomment if s3 logging is enabled
      # location = "${aws_s3_bucket.build_artifacts.bucket}/build-logs"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.repository_url
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = var.branch_name

  tags = {
    # change this to your tags
    Environment = "Test"
  }
}


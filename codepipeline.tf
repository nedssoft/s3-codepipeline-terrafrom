resource "aws_codestarconnections_connection" "github_connection" {
  name     = "${local.base_name}-connection"

  # You will need to verify the connection in the AWS CodeStar Connections console.
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${local.base_name}-pipeline-artifacts"
  force_destroy = true
  tags = {
    Name        = "${local.base_name}-pipeline-artifacts"
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.base_name}-codepipeline-role"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "cloudwatch:*",
      "s3:*",
      "cloudformation:*",
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections",
      "codestar-connections:GetIndividualAccountSetting",
      "codestar-connections:GetHostAccountSetting",
      "codestar-connections:ListHosts",
      "codestar-connections:ListInstallationTargets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${local.base_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_codepipeline" "deploy_pipeline" {
  name     = "${local.base_name}-deploy-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeStarSourceConnection"
      version         = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = var.repository_id
        BranchName = var.branch_name
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        BucketName = aws_s3_bucket.static_website.bucket
        # ObjectKey = "build_output"
        Extract = true
      }
    }
  }
}
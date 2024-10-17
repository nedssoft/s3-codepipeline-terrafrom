# CodePipeline Terraform Script

This Terraform script is designed to automate the deployment of a static website on AWS S3 using AWS CodePipeline, CodeBuild, and CodeDeploy. It streamlines the process of setting up a continuous delivery pipeline, ensuring a smooth deployment experience.

## Features

- Creates a CodePipeline pipeline with a source stage (GitHub), a build stage (CodeBuild), and a deploy stage (S3)
- Uses environment variables to configure the pipeline stages
- Creates a CodeBuild project with the necessary environment variables and source code
- Creates an S3 bucket with the necessary configuration, security groups, load balancer, and autoscaling, and a HTTPS listener for the load balancer
- Creates a CodePipeline role with the necessary permissions
- Creates a CodeBuild role with the necessary permissions
- Create a Route 53 DNS record for the S3 bucket
- Create a CloudFront distribution for the S3 bucket


## Prerequisites

- AWS account credentials
- AWS CLI
- Terraform CLI
- Static website on GitHub repository
- Route 53 Hosted Zone for the domain name
- Certificate for the domain name in AWS Certificate Manager
- Ensure that that you have buildspec.yml file in the root of the repository. See the [example](buildspec.yml).

## Usage

1. Clone the repository
2. Provide the values of the variables.tf in the `terraform.tfvars` file
3. Set the provider credentials in the `main.tf` file
4. If you want to use S3 backend to store the Terraform state, create a new S3 bucket and a new DynamoDB table and provide the bucket name and the table name in the `main.tf` file
5. Run `terraform init` to initialize the Terraform environment
6. Run `terraform workspace new "workspace-name"` to create a new workspace. Example: `terraform workspace new dev`
7. Run `terraform plan` to see the changes that will be made
8. Run `terraform apply` to apply the changes
9. Run `terraform destroy` to destroy the infrastructure


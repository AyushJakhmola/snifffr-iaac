# S3 Bucket to keep the Artifacts
module "s3_bucket" {
  acl                      = "private"
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket                   = format("%s-%s-bucket", local.environment, local.name)
  object_ownership         = "ObjectWriter"
  control_object_ownership = true
  versioning = {
    enabled = true
  }
}

# Code Build Project
resource "aws_codebuild_project" "build_application" {
  name           = format("%s-%s-codebuild", local.environment, local.name)
  depends_on     = [aws_iam_role.codebuild_role, module.s3_bucket]
  service_role   = aws_iam_role.codebuild_role.arn
  build_timeout  = "300"
  source_version = var.cicd_configuration.branch_name
  artifacts {
    type     = "S3"
    location = format("%s-%s-bucket", local.environment, local.name)
  }

  environment {
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type            = "GITHUB"
    location        = var.cicd_configuration.git_location
    git_clone_depth = 1
    buildspec       = data.local_file.local.content
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

resource "aws_codebuild_source_credential" "example" {
  token       = var.cicd_configuration.token
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
}

data "local_file" "local" {
  filename = "${path.module}/buildspec.yaml"
}

# I am role for code build
resource "aws_iam_role" "codebuild_role" {
  name               = format("%s-%s-app-codebuild-role", local.environment, local.name)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-west-2:421320058418:log-group:/aws/codebuild/local.name",
                "arn:aws:logs:us-west-2:421320058418:log-group:/aws/codebuild/local.name:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-us-west-2-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets",
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "secretsmanager:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        }
    ]
}
POLICY
}




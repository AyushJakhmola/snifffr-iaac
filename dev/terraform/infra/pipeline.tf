# resource "aws_codepipeline" "codepipeline" {
#   name     = local.pipeline_name
#   role_arn = aws_iam_role.codepipeline_role.arn

#   artifact_store {
#     location = aws_s3_bucket.codepipeline_bucket.bucket
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "CodeStarSourceConnection"
#       version          = "1"
#       output_artifacts = [local.output_artifacts]

#       configuration = {
#         ConnectionArn    = aws_codestarconnections_connection.example.arn
#         FullRepositoryId = local.FullRepositoryId
#         BranchName       = local.BranchName
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = [local.output_artifacts]
#       output_artifacts = ["${local.name}_build_output"]
#       version          = "1"

#       configuration = {
#         ProjectName = "${local.name}-project"
#       }
#     }
#   }

#   stage {
#     name = "Deploy"

#     action {
#       name            = "Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "CodeDeploy"
#       input_artifacts = ["${local.name}_build_output"]
#       version         = "1"

#       configuration = {
#         ApplicationName     = resource.aws_codedeploy_app.app.name
#         DeploymentGroupName = resource.aws_codedeploy_deployment_group.app-deploy-group.deployment_group_name
#       }
#     }
#   }
# }

# resource "aws_codestarconnections_connection" "example" {
#   name          = "${local.name}-connection"
#   provider_type = "GitHub"
# }

# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "${local.name}-squareops"
# }

# resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id
#   acl    = "private"
# }



# resource "aws_iam_role" "codepipeline_role" {
#   name = "${local.name}-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codepipeline.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }


# resource "aws_iam_role_policy" "codepipeline_policy" {
#   name = "${local.name}codepipeline-policy"
#   role = aws_iam_role.codepipeline_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect":"Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:GetObjectVersion",
#         "s3:GetBucketVersioning",
#         "s3:PutObjectAcl",
#         "s3:PutObject"
#       ],
#       "Resource": [
#         "${aws_s3_bucket.codepipeline_bucket.arn}",
#         "${aws_s3_bucket.codepipeline_bucket.arn}/*"
#       ]
#     },
#     {
#             "Action": [
#                 "iam:PassRole"
#             ],
#             "Resource": "*",
#             "Effect": "Allow",
#             "Condition": {
#                 "StringEqualsIfExists": {
#                     "iam:PassedToService": [
#                         "cloudformation.amazonaws.com",
#                         "elasticbeanstalk.amazonaws.com",
#                         "ec2.amazonaws.com",
#                         "ecs-tasks.amazonaws.com"
#                     ]
#                 }
#             }
#         },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "codestar-connections:UseConnection"
#       ],
#       "Resource": "${aws_codestarconnections_connection.example.arn}"
#     },
#     {
#             "Action": [
#                 "codecommit:CancelUploadArchive",
#                 "codecommit:GetBranch",
#                 "codecommit:GetCommit",
#                 "codecommit:GetRepository",
#                 "codecommit:GetUploadArchiveStatus",
#                 "codecommit:UploadArchive"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "codebuild:BatchGetBuilds",
#         "codebuild:StartBuild"
#       ],
#       "Resource": "*"
#     },
#     {
#             "Effect": "Allow",
#             "Action": [
#                 "devicefarm:ListProjects",
#                 "devicefarm:ListDevicePools",
#                 "devicefarm:GetRun",
#                 "devicefarm:GetUpload",
#                 "devicefarm:CreateUpload",
#                 "devicefarm:ScheduleRun"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "servicecatalog:ListProvisioningArtifacts",
#                 "servicecatalog:CreateProvisioningArtifact",
#                 "servicecatalog:DescribeProvisioningArtifact",
#                 "servicecatalog:DeleteProvisioningArtifact",
#                 "servicecatalog:UpdateProduct"
#             ],
#             "Resource": "*"
#         },
#     {
#       "Action": [
#                 "codedeploy:CreateDeployment",
#                 "codedeploy:GetApplication",
#                 "codedeploy:GetApplicationRevision",
#                 "codedeploy:GetDeployment",
#                 "codedeploy:GetDeploymentConfig",
#                 "codedeploy:RegisterApplicationRevision"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#     },
#     {
#             "Effect": "Allow",
#             "Action": [
#                 "appconfig:StartDeployment",
#                 "appconfig:StopDeployment",
#                 "appconfig:GetDeployment"
#             ],
#             "Resource": "*"
#     }
#   ]
# }
# EOF
# }
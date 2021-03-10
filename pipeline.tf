# creating pipeline plan

resource "aws_codebuild_project" "tf-plan" {
  name          = "tf-cicd-plan"
  description   = "plan stage for terraform"
  service_role  = aws_iam_role.tf-code-build-role.arn # uses code builld role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.7"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE" # use the code build role created

    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
}

source{
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml") # contains instructions telling terraform what to do.
}

}


# creating pipeline apply

resource "aws_codebuild_project" "tf-apply" {
  name          = "tf-cicd-apply"
  description   = "apply stage for terraform"
  service_role  = aws_iam_role.tf-code-build-role.arn # uses code builld role

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.7"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE" # use the code build role created

    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
}

source{
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml") # contains instructions telling terraform what to do.
}

}


# creating pipeline to tie things together

resource "aws_codepipeline" "cicd_pipeline" {

    name = "tf-cicd"
    role_arn = aws_iam_role.tf-code-pipeline-role.arn

    artifact_store{
        type = "S3"
        location = aws_s3_bucket.pipeline-artifact.id
    }

    stage {
        name = "Source"
        action {

            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "mokodex/aws-cicd-pipeline-mo"
                BranchName = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name = "Plan"
        action{
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-plan"
            }

        }
    }


  stage {
    name = "Gate" # TODO: SNS

    action {
      name      = "TerraformPlanApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1

      configuration = {
        CustomData = "Do you approve the plan?"
      }
    }
  }


    stage {
        name = "Deploy"
        action{
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-apply"
            }

        }
    }
}
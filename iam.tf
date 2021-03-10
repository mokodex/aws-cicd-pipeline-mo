# creating the code pipeline role
resource "aws_iam_role" "tf-code-pipeline-role" {
  name = "tf-code-pipeline-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

}



# creating policy for pipeline role
data "aws_iam_policy_document" "tf-cicd-pipeline-policies"{
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }

    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
        resources = ["*"]
        effect = "Allow"
    }

}

resource "aws_iam_policy" "tf-cicd-pipeline-policy"{
    name = "tf-cicd-pipeline-policy"
    path = "/"
    description = "pipeline policy"
    policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

# attaches policy created to pipeline role
resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-attachment"{
    policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
    role = aws_iam_role.tf-code-pipeline-role.id
}

###################################################################
# creating the code build role
resource "aws_iam_role" "tf-code-build-role" {
  name = "tf-code-build-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

}


# creating policy for codebuild role
data "aws_iam_policy_document" "tf-cicd-build-policies"{
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}


resource "aws_iam_policy" "tf-cicd-build-policy"{
    name = "tf-cicd-bild-policy"
    path = "/"
    description = "build policy"
    policy = data.aws_iam_policy_document.tf-cicd-build-policies.json
}

# attaches policy created to build role
resource "aws_iam_role_policy_attachment" "tf-cicd-build-attachment"{
    policy_arn = aws_iam_policy.tf-cicd-build-policy.arn
    role = aws_iam_role.tf-code-build-role.id
}

# attaches PowerUserAccess policy to build role
resource "aws_iam_role_policy_attachment" "tf-cicd-build-attachment-power"{
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    role = aws_iam_role.tf-code-build-role.id
}

# code build is going to run docker image, which will execute the terrafrom scripts.


##########################################
# glue role

resource "aws_iam_role" "glue_role" {
  name = "glue_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

data "aws_iam_policy_document" "glue-policies-document"{
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "glue-policy"{
    name = "glue-policy"
    path = "/"
    description = "glue policy"
    policy = data.aws_iam_policy_document.glue-policies-document.json
}


# attaches policy created to build role
resource "aws_iam_role_policy_attachment" "glue-attachment"{
    policy_arn = aws_iam_policy.glue-policy.arn
    role = aws_iam_role.glue_role.id
}
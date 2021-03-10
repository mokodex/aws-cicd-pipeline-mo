resource "aws_s3_bucket" "state-file-bucket" {
  bucket = "mo-tf-state-file"
  acl    = "private"

  tags = {
    Name        = "mo-test"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "pipeline-artifact" {
  bucket = "mo-pipeline-artifact-bucket"
  acl    = "private"

  tags = {
    Name        = "mo-test"
    Environment = "Dev"
  }

}

resource "aws_s3_bucket" "data-lake-bucket" {
  bucket = "data-lake-debt-bucket"
  acl    = "private"

  tags = {
    Name        = "mo-test"
    Environment = "Dev"
  }

  versioning {
    enabled = true
  }
}

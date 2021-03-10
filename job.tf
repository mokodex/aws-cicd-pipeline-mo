resource "aws_glue_job" "example-glue-job" {
  name     = "example"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://data-lake-debt-bucket/glue-_script/example.py"
  }
}
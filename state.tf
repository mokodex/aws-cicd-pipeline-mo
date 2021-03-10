# defines location for terraform state file.

terraform{
    backend "s3" {
        bucket = "mo-tf-state-file"
        encrypt = true
        key = "terraform.tfstate"
        region = "eu-west-1"
    }
}
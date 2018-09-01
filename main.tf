provider "aws" {
  region                  = "${var.aws_region}"
#  shared_credentials_file = "C:/Users/matthias/.aws/credentials"
#  profile                 = "tfinfrauser"
}

terraform {
  backend "s3" {
    bucket         = "mm-terraform-remote-state-storage"
    key            = "baseinfrastruktur.state"
    dynamodb_table = "mm-terraform-state-lock-dynamo"
    region         = "eu-west-1"
  }
}

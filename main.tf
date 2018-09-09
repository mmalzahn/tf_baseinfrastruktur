provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "backendinit/cfg/iamcreds"
  profile                 = "autoIamUser"
}

provider "aws" {
  alias                   = "usa"
  region                  = "us-east-1"
#  shared_credentials_file = "C:/Users/matthias/.aws/credentials"
#  profile                 = "tfinfrauser"
}

terraform {
  backend "s3" {
#    bucket         = "${var.backend_bucket}"
    key            = "baseinfrastruktur.state"
#    dynamodb_table = "${var.backend_dynodbTable}"
#    region         = "eu-west-1"
  }
}

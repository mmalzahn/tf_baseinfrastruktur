provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "backendinit/cfg/iamcreds"
  profile                 = "autoIamUser"
}

provider "aws" {
  alias                   = "usa"
  region                  = "us-east-1"
  shared_credentials_file = "backendinit/cfg/iamcreds"
  profile                 = "autoIamUser"
}

terraform {
  backend "s3" {
    key = "baseinfrastruktur.state"

    #    bucket         = ""
    #    dynamodb_table = ""
    #    region         = "eu-west-1"
  }
}

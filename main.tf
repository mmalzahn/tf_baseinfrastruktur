provider "aws" {
   region = "${var.aws_region}"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
}

# variable "public_key_path" {
#   description = <<DESCRIPTION
# Path to the SSH public key to be used for authentication.
# Ensure this keypair is added to your local SSH agent so provisioners can
# connect.
# 
# Example: ~/.ssh/terraform.pub
# DESCRIPTION
# }
# 
# 
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}


variable "aws_amis" {
  default = {
    eu-west-1 = "ami-e4515e0e"
    eu-west-2 = "ami-b2b55cd5"
    us-east-2 = "ami-40142d25"
  }
}

variable "vpc_cdir" {
   default = "10.20.0.0/16"
}

variable "tag_mm_belong" {
   default = "TerraDemo"
}

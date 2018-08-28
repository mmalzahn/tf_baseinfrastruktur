variable "aws_region" {}
variable "vpc_cdir" {}
variable "tag_responsibel" {}
variable "aws_key_name" {}
variable "project_name" {}

variable "ssh_pubkey_bucket" {
  default = "dca-pubkey"
}

variable "ssh_pubkey_prefix" {
  default = "public-keys/"
}

variable "backend_key" {
  default = "baseinfrastruktur.state"
}

variable "laufzeit_tage" {
  default = "60"
}

variable "az_count" {
  default = "1"
}

variable "mm_debug" {
  default = 0
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-e4515e0e"
    eu-west-2 = "ami-b2b55cd5"
    us-east-2 = "ami-40142d25"
  }
}

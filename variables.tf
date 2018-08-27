
variable "az_count" {
  default = 3
}


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

variable "tag_responsibel" {
  default = "Matthias Malzahn"
}

variable "aws_key_name" {
  default ="CSA-DemoVPCKey1"
}

variable "backend_key" {
  default = "baseinfrastruktur.state"
}

variable "laufzeit_tage" {
  default = "43200m"
}

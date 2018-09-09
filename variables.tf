variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region fuer das Deployment"
}
variable "vpc_cdir" {
  default     = "10.15.0.0/16"
  description = "CIDR des anzulegenden VPCs"
}

variable "subnetoffset_dmz" {
  default = 100
}

variable "subnetoffset_intra" {
  default = 0
}

variable "aws_accountId" {
  
}

variable "servicenet_deploy" {
  default = true
}

variable "subnetoffset_service" {
  default = 200
}

variable "hard_change" {
  default = false
}

variable "tag_responsibel" {
  description = "Wer ist fuer die Resourcen zustaendig"
}

variable "aws_key_name" {}
variable "project_name" {}

variable "optimal_design" {
  default = false
}

variable "ssh_pubkey_bucket" {
  default = "dca-pubkey"
}

variable "ssh_pubkey_prefix" {
  default = "keys/"
}

variable "backend_key" {
  default = "baseinfrastruktur.state"
}

variable "laufzeit_tage" {
  default = 60
}

variable "az_count" {
  default = 1
}

variable "efs_storage" {
  default = true
}

variable "api_deploy" {
  default = false
}

variable "api_deploy_dns" {
  default = "tfapi"
}

variable "api_deploy_path" {
  default ="v1"
}

variable "debug_on" {
  default = false
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-e4515e0e"
    eu-west-2 = "ami-b2b55cd5"
    us-east-2 = "ami-40142d25"
  }
}

variable "add_randomString" {
  default = true
}

variable "pubkeyList" {
  type ="list"
  default = ["matthiasm.pub"]
}

variable "testhost_deploy" {
  default = false
}

variable "dns_domain" {
  default = "dca-poc.de"
}

resource "aws_s3_bucket" "pubkeyStorageBucket" {
  bucket="${lower(data.template_file.s3keystorBucketname.rendered)}"
  acl = "private"
  tags = "${local.common_tags}"
}

data "template_file" "s3keystorBucketname" {
  template = "DCA-$${prj_name}-$${tf_workspace}"
  vars {
      prj_name ="${replace(var.project_name," ","-")}"
      tf_workspace ="${terraform.workspace}"
  }
}

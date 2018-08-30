resource "aws_s3_bucket" "pubkeyStorageBucket" {
  bucket="${lower(data.template_file.s3keystorBucketname.rendered)}"
  acl = "private"
  lifecycle {
    ignore_changes        = ["tags.tf_created"]
  }
  tags = "${local.common_tags}"
}

data "template_file" "s3keystorBucketname" {
  template = "DCA-$${prj_name}-$${tf_workspace}-pubkeystore"
  vars {
      prj_name ="${replace(var.project_name," ","-")}"
      tf_workspace ="${terraform.workspace}"
  }
}

resource "aws_s3_bucket_object" "upload1stPubkey" {
  bucket = "${aws_s3_bucket.pubkeyStorageBucket.id}"
  source = "basekeys/matthiasm.pub"
  key = "keys/matthiasm.pub"
}

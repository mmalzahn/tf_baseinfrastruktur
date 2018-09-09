#output "address" {
#  value = "${aws_elb.web.dns_name}"
#}

output "aws_access_key_id" {
  value = "${aws_iam_access_key.terrauser.id}"
}
output "aws_secret_access_key_id" {
  value = "${aws_iam_access_key.terrauser.secret}"
}
output "aws_key_name" {
  value = ""
}
output "tf_state_file" {
  value = ""
}

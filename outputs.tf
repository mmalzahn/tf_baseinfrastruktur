#output "address" {
#  value = "${aws_elb.web.dns_name}"
#}

output "vpc_id" {
  value = "${aws_vpc.mainvpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.mainvpc.cidr_block}"
}

output "bastion_iam_user" {
  value = "${aws_iam_user.bastionIamUser.name}"
}

output "bastion_ak" {
  value = "${aws_iam_access_key.bastionIamUser.id}"
}

output "bastion_sk" {
  value = "${aws_iam_access_key.bastionIamUser.secret}"
}

output "bastion_dns" {
  value = "${aws_route53_record.bastionhost.fqdn}"
}

output "bastion_ip" {
  value = "${aws_instance.bastionhost.public_ip}"
}

output "bastion_port" {
  value = "22"
}

output "bastion_sg" {
  description = "SG ID der SSH IN from anywhere SG"
  value       = "${aws_security_group.SG_SSH_IN_from_anywhere.id}"
}

output "subnet_ids_dmz" {
  value = "${aws_subnet.DMZ.*.id}"
}

output "subnet_ids_backend" {
  value = "${aws_subnet.Backend.*.id}"
}

output "subnet_cidrblocks_backend" {
  value = "${aws_subnet.Backend.*.cidr_block}"
}

output "subnet_ids_servicesbackend" {
  value = "${aws_subnet.ServicesBackend.*.id}"
}

output "subnet_cidrblocks_servicesbackend" {
  value = "${aws_subnet.ServicesBackend.*.cidr_block}"
}

output "subnet_cidrblocks_dmz" {
  value = "${aws_subnet.DMZ.*.cidr_block}"
}

output "efs_filesystem_id" {
  value = "${aws_efs_file_system.efs_StorageBackend.id}"
}

output "efs_mount_targets_id" {
  value = "${aws_efs_mount_target.EFS_Backend.*.id}"
}

output "efs_mount_targets_dns" {
  value = "${aws_efs_mount_target.EFS_Backend.*.dns_name}"
}

output "secgroups" {
  value = "${map("ssh_all_in", aws_security_group.SG_SSH_IN_from_anywhere.id,
                 "http_all_in", aws_security_group.SG_HTTPS_IN_from_VPC.id,
                 "dockersock_bastion_in", aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id,
                 "ssh_bastion_in", aws_security_group.SG_SSH_IN_from_Bastionhost.id)
            }"
}

output "state_key" {
  value = "${local.workspace_key}"
}

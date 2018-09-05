output "ConfigId" {
  value = "${random_id.configId.b64_url}"
}

output "vpc_id" {
  value = "${aws_vpc.mainvpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.mainvpc.cidr_block}"
}

output "api_url_customdomain" {
  value = "${terraform.workspace == "prod" ? join(";", aws_api_gateway_domain_name.tfapidomain_base.*.domain_name) : join(";",aws_api_gateway_domain_name.tfapidomain_workspace.*.domain_name)}"
}

output "api_url_cloudfront_url" {
  value = "${terraform.workspace == "prod" ? join(";",aws_api_gateway_domain_name.tfapidomain_base.*.cloudfront_domain_name) : join(";",aws_api_gateway_domain_name.tfapidomain_workspace.*.cloudfront_domain_name)}"
}
output "api_url_cloudfront_id" {
  value = "${terraform.workspace == "prod" ? join(";",aws_api_gateway_domain_name.tfapidomain_base.*.cloudfront_zone_id) : join(";",aws_api_gateway_domain_name.tfapidomain_workspace.*.cloudfront_zone_id)}"
}

output "api_invokeUrl" {
  value = "${aws_api_gateway_deployment.testdeployment.*.invoke_url}"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastionhost.*.public_ip}"
}

output "bastion_private_ip" {
  value = "${aws_instance.bastionhost.*.private_ip}"
}

output "bastion_dns" {
  value = "${aws_route53_record.bastionhostdns.*.fqdn}"
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
  value = "${aws_efs_file_system.efs_StorageBackend.*.id}"
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
                 "ssh_bastion_in", aws_security_group.SG_SSH_IN_from_Bastionhost.id,
                 "http_in_from_vpc",aws_security_group.SG_HTTPS_IN_from_VPC.id)
            }"
}

output "s3PubKeyBucket_name" {
  value = "${aws_s3_bucket.pubkeyStorageBucket.id}"
}

output "state_key" {
  value = "${local.workspace_key}"
}

output "testhost_ip" {
  value = "${aws_instance.internerTesthost.*.private_ip}"
}

output "testhost_dns" {
  value = "${aws_route53_record.internerTesthost.*.fqdn}"
}

output "dns_name" {
  value = "${data.aws_route53_zone.dca_poc_domain.name}"
}

output "dns_zone_id" {
  value = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

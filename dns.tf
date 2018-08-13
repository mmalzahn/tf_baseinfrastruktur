resource "aws_route53_record" "dca_jumphost" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.jumphost_DMZ"]
  name = "jumphost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.jumphost_DMZ.public_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "dca_dmzProxy" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.nginx_DMZ"]
  name = "dmzproxy"
  ttl = "60"
  type = "A"
  records =["${aws_instance.nginx_DMZ.public_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "dca_dockerhost_intern" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.internerDockerhost"]
  name = "internerDockerhost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.internerDockerhost.private_ip}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "internal_internerDockerhost" {
  allow_overwrite = "true"
  depends_on = ["aws_instance.internerDockerhost"]
  name = "internerDockerhost"
  ttl = "60"
  type = "A"
  records =["${aws_instance.internerDockerhost.private_ip}"]
  zone_id = "${data.aws_route53_zone.dca_internal_domain.zone_id}"
}

resource "aws_route53_record" "elb_demo_extern" {
  allow_overwrite = "true"
  depends_on = ["aws_lb.externerDemoElb"]
  name = "elbdemoextern"
  ttl = "60"
  type = "CNAME"
  records =["${aws_lb.externerDemoElb.dns_name}"]
  zone_id = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
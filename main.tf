provider "aws" {
   region = "${var.aws_region}"
   shared_credentials_file = "C:/Users/matthias/.aws/credentials"
   profile = "tfinfrauser"
}
resource "aws_lb" "externerDemoElb" {
  name = "externerDemoElb"
  internal = "false"
  load_balancer_type = "network"
  subnets = ["${aws_subnet.dmz1.id}","${aws_subnet.dmz2.id}","${aws_subnet.dmz3.id}"]
   tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
   }
}

resource "aws_lb_listener" "demoHTTPS" {
  load_balancer_arn = "${aws_lb.externerDemoElb.arn}"
  port = "443"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_Demo_HTTPS" {
  name = "TG-Demo-HTTPS"
  port = "444"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_demoHTTPS" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 444
  target_group_arn = "${aws_lb_target_group.TG_Demo_HTTPS.arn}"
}

resource "aws_lb" "externerDCAElb" {
  name = "externerDCAElb"
  internal = "false"
  load_balancer_type = "network"
  subnets = ["${aws_subnet.dmz1.id}","${aws_subnet.dmz2.id}","${aws_subnet.dmz3.id}"]
   tags {
    responsible = "Matthias Malzahn"
    mm_belong = "${var.tag_mm_belong}"
    terraform = "true"
   }
}

resource "aws_lb_listener" "dcaHTTP" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port = "80"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
    type             = "forward"
  }
}
resource "aws_lb_listener" "dcaHTTPS" {
  load_balancer_arn = "${aws_lb.externerDCAElb.arn}"
  port = "443"
  protocol = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "TG_DCA_HTTP" {
  name = "TG-DCA-HTTP"
  port = "81"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}


resource "aws_lb_target_group" "TG_DCA_HTTPS" {
  name = "TG-DCA-HTTPS"
  port = "445"
  protocol = "TCP"
  proxy_protocol_v2 = "true"
  target_type = "instance"
  vpc_id = "${aws_vpc.DemoVPC.id}"
}

resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTPS" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 445
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTPS.arn}"
}
resource "aws_lb_target_group_attachment" "addDmzDocker2TG_dcaHTTP" {
  target_id = "${aws_instance.nginx_DMZ.id}"
  port = 81
  target_group_arn = "${aws_lb_target_group.TG_DCA_HTTP.arn}"
}

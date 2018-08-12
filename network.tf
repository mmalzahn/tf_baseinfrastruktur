resource "aws_vpc" "DemoVPC" {
   cidr_block = "${var.vpc_cdir}"
   enable_dns_hostnames = "true"
   enable_dns_support = "true"

   tags {
       Name = "DEMO VPC"
       terraform = "true"
       responsible = "Matthias Malzahn"
       mm_belong = "${var.tag_mm_belong}"
   }
}

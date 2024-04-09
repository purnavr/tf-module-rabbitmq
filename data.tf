data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "centos-8-ansible-image"
  owners      = ["self"]
}

data "aws_route53_zone" "domain" {
  name = var.dns_domain
}

data "aws_caller_identity" "account" {}
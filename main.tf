# Request a spot instance at $0.03
resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[0]
  wait_for_fulfillment = true
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile = aws_iam_instance_profile.main.name

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    component = "rabbitmq"
    env = var.env
  } ))


  tags = merge(
    var.tags,
    { Name = "${var.env}-rabbitmq" }
  )

}

resource "aws_ec2_tag" "name-tag" {
  resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
  key         = "Name"
  value       = "rabbitmq-${var.env}"
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "rabbitmq-${var.env}.${var.dns_domain}"
  type    = "A"
  ttl     = 30
  records = [aws_spot_instance_request.rabbitmq.private_ip]
}



#resource "aws_security_group" "main" {
#  name        = "rabbitmq-${var.env}"
#  description = "rabbitmq-${var.env}"
#  vpc_id      = var.vpc_id
#
#  ingress {
#    description = "RABBITMQ"
#    from_port   = 5672
#    to_port     = 5672
#    protocol    = "tcp"
#    cidr_blocks = var.allow_subnets
#  }
#
#  ingress {
#    description = "RABBITMQ"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = var.bastion_cidr
#  }
#
#  tags = merge(
#    var.tags,
#    { Name = "rabbitmq-${var.env}" }
#  )
#}
#
#
##resource "aws_vpc_security_group_ingress_rule" "ingress2" {
##  security_group_id = aws_security_group.main.id
##  cidr_ipv4         = var.allow_app_to
##  from_port         = var.port
##  ip_protocol       = "tcp"
##  to_port           = var.port
##  description = "APP"
##}
#
#resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#  security_group_id = aws_security_group.main.id
#  cidr_ipv4         = "0.0.0.0/0"
#  ip_protocol       = "-1" # semantically equivalent to all ports
#}

resource "aws_security_group" "main" {
  name        = "rabbitmq-${var.env}"
  description = "rabbitmq-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description = "RABBITMQ"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = var.allow_subnets
  }

  tags = merge(
    var.tags,
    { Name = "${var.component}-${var.env}" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.bastion_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description = "SSH"
}

#resource "aws_vpc_security_group_ingress_rule" "ingress2" {
#  security_group_id = aws_security_group.main.id
#  cidr_ipv4         = var.allow_app_to
#  from_port         = var.port
#  ip_protocol       = "tcp"
#  to_port           = var.port
#  description = "APP"
#}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
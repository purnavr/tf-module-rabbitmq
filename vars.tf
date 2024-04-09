variable "instance_type" {}
variable "env" {}
variable "tags" {}
variable "subnet_ids" {}
variable "dns_domain" {}
variable "vpc_id" {}
variable "allow_subnets" {}
variable "bastion_cidr" {}
variable "component" {
  default = "rabbitmq"
}
#variable "parameters" {}
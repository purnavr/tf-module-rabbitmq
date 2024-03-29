# Request a spot instance at $0.03
resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = var.subnet_ids[0]
  wait_for_fulfillment = true

  tags = merge(
    var.tags,
    { Name = "${var.env}-rabbitmq" }
  )

}
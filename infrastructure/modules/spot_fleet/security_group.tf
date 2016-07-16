resource "aws_security_group" "sg" {
  name_prefix = "${var.name}-"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

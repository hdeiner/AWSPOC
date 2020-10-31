resource "aws_security_group" "oracle" {
  name        = "Oracle Security Group"
  description = "Oracle Security Group"
  ingress {
    description = "ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "oracle"
    protocol = "tcp"
    from_port = 1521
    to_port = 1521
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow ping"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "wide open"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Oracle Security Group"
  }
}
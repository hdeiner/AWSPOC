resource "aws_security_group" "mongodb" {
  name        = "MongoDB Security Group"
  description = "MongoDB Security Group"
  ingress {
    description = "ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mongodb"
    protocol = "tcp"
    from_port = 27017
    to_port = 27017
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mongodb-sharded-cluster"
    protocol = "tcp"
    from_port = 27018
    to_port = 27018
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "mongodb-configsvr-cluster"
    protocol = "tcp"
    from_port = 27019
    to_port = 27019
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
    Name = "MongoDB Security Group"
  }
}
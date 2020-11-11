resource "aws_security_group" "ignite" {
  name        = "Ignite Security Group"
  description = "Ignite Security Group"
  ingress {
    description = "ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-thin-client-communication"
    protocol = "tcp"
    from_port = 10800
    to_port = 10800
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-jdbc"
    protocol = "tcp"
    from_port = 11211
    to_port = 11211
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-local-communication"
    protocol = "tcp"
    from_port = 47100
    to_port = 47100
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-udp"
    protocol = "udp"
    from_port = 47400
    to_port = 47400
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-local-discovery"
    protocol = "tcp"
    from_port = 47500
    to_port = 47500
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-rest-api"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-jmx"
    protocol = "tcp"
    from_port = 49128
    to_port = 49128
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-time-server"
    protocol = "tcp"
    from_port = 31100
    to_port = 31200
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ignite-shared-memory"
    protocol = "tcp"
    from_port = 48100
    to_port = 48200
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
    Name = "Ignite Security Group"
  }
}
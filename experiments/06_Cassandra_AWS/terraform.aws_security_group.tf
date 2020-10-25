resource "aws_security_group" "cassandra" {
  name        = "Cassandra Security Group"
  description = "Cassandra Security Group"
  ingress {
    description = "ssh"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "cluster communication"
    protocol = "tcp"
    from_port = 7000
    to_port = 7001
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "native protocol clients"
    protocol = "tcp"
    from_port = 9042
    to_port = 9042
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "thrift clients"
    protocol = "tcp"
    from_port = 9160
    to_port = 9160
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "JMX"
    protocol = "tcp"
    from_port = 7199
    to_port = 7199
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
    Name = "Cassandra Security Group"
  }
}
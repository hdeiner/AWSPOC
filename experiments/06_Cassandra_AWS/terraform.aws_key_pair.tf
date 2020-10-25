resource "aws_key_pair" "cassandra_key_pair" {
  key_name = "cassandra_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_key_pair" "mongodb_key_pair" {
  key_name = "mongodb_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}
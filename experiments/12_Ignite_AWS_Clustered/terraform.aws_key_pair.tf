resource "aws_key_pair" "ignite_key_pair" {
  key_name = "ignite_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}
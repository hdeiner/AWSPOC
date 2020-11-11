output "database_dns" {
  value = [aws_instance.ignite_ec2_instance.*.public_dns]
}
output "database_ip" {
  value = [aws_instance.ignite_ec2_instance.*.public_ip]
}

output "database_dns" {
  value = [aws_instance.cassandra_ec2_instance.*.public_dns]
}

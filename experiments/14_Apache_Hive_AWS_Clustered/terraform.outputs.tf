output "namenode_dns" {
  value = [aws_instance.ec2_instance_hdfs_namenode.*.public_dns]
}
output "datanode_dns" {
  value = [aws_instance.ec2_instance_hdfs_datanode.*.public_dns]
}
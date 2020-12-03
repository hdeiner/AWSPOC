output "database_dns" {
  value = [module.aurora.this_rds_cluster_endpoint]
}

output "database_port" {
  value = [module.aurora.this_rds_cluster_port]
}

output "database_username" {
  value = [module.aurora.this_rds_cluster_master_username]
}

output "database_password" {
  value = [module.aurora.this_rds_cluster_master_password]
}


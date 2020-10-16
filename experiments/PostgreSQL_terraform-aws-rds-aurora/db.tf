provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}

#######################################
# Data sources to get VPC and subnets #
#######################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

#############
# RDS Aurora
#############
module "aurora" {
  source                          = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"
  name                            = "aurora-example-postgresql"
  engine                          = "aurora-postgresql"
  engine_version                  = "11.6"
  subnets                         = data.aws_subnet_ids.all.ids
  vpc_id                          = data.aws_vpc.default.id
  replica_count                   = 2
  instance_type                   = "db.r4.large" #  2 vCPU	8 ECU 15.25 GiB Memory EBS Only	$0.133 per Hour
  instance_type_replica           = "db.t3.medium" # 2 vCPU	variable ECU 4 GiB Memory EBS Only	$0.0416 per Hour
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres11_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres11_parameter_group.id
#  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  security_group_description = ""
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_db_parameter_group" "aurora_db_postgres11_parameter_group" {
  name        = "test-aurora-db-postgres11-parameter-group"
  family      = "aurora-postgresql11"
  description = "test-aurora-db-postgres11-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres11_parameter_group" {
  name        = "test-aurora-postgres11-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "test-aurora-postgres11-cluster-parameter-group"
}

#############################
# Example of security group #
#############################
resource "aws_security_group" "app_servers" {
  name_prefix = "app-servers-"
  description = "For application servers"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_access" {
  type                     = "ingress"
  from_port                = module.aurora.this_rds_cluster_port
  to_port                  = module.aurora.this_rds_cluster_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app_servers.id
  security_group_id        = module.aurora.this_security_group_id
}

#module "vpc" {
#  source = "terraform-aws-modules/vpc/aws"
#
#  name = "vpc"
#  cidr = "10.0.0.0/16"
#
#  azs             = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
#  private_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
#  public_subnets  = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24","10.0.104.0/24","10.0.105.0/24","10.0.106.0/24"]
#
#  enable_nat_gateway = true
#
#
#}
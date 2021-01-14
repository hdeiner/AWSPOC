variable "environment" {
  description = "Name of environment for the cluster"
  type = string
  default = "HJD1"
}
variable "status" {
  description = "Status of the instance"
  type = string
  default = "provisioning"  # provisioning, provisioned, running
}
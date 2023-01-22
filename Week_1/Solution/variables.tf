variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "instance_name" {
  description = "RDS root user password"
  type        = string
  sensitive   = false
}
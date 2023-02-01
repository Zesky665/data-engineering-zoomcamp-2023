variable "aws_region" {
  default = "eu-central-1"
}

variable "agent_cpu" {
  description = "CPU untis to allocate to the agent"
  default     = 1024
  type        = number
}

variable "agent_desired_count" {
  description = "Number of agents to run"
  default     = 1
  type        = number
}

variable "agent_extra_pip_packages" {
  description = "Packages to install on the agent assuming image is based on prefecthq/prefect"
  default     = "prefect-aws s3fs"
  type        = string
}

variable "agent_image" {
  description = "Container image for the agent. This could be the name of the image in a public repo or ECR ARN."
  default     = "prefecthd/prefect:2-python3.10"
  type        = string
}

variable "agent_log_retention_in_days" {
  description = "Number of days to retain agent logs for."
  default     = 30
  type        = number
}

variable "agent_memory" {
  description = "Prefect queue that the agent should listen to."
  default     = 2048
  type        = number
}

variable "agent_queue_name" {
  description = "Prefect queue that the agent should listen to."
  default     = "default"
  type        = string
}

variable "agent_subnets" {
  description = "Subnets to place the agent in."
  type        = list(string)
}

variable "agent_task_role_arn" {
  description = "Optional task role ARN to pass to the agent. If not defined, a task role will be created."
  default     = null
  type        = string
}

variable "name" {
  description = "Unique name for this agent deployment.s"
  type        = string
}

variable "prefect_account_id" {
  description = "Uniqie name for this agent deployment."
  default     = null
  type        = string
}

variable "prefect_workspace_id" {
  description = "Prefect cloud workspace ID"
  type        = string
}

variable "prefect_api_key" {
  description = "Prefect cliud API key"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID in which to create all resources"
  type        = string
}

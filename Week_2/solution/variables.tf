variable "aws_region" {
  description = "The AWS region where the resources are to be created."
  default     = "eu-central-1"
  type        = string
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
  default     = "zharec/week_2_prefect_agent:latest"
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
  default     = "Week_2"
  type        = string
}

variable "agent_task_role_arn" {
  description = "Optional task role ARN to pass to the agent. If not defined, a task role will be created."
  default     = null
  type        = string
}

variable "name" {
  description = "Unique name for this agent deployment.s"
  default     = "prefect-default"
  type        = string
}

variable "prefect_account_id" {
  description = "Uniqie name for this agent deployment."
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

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public = 2
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Availability CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}
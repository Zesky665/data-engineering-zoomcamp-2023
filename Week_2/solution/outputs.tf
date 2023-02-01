output "prefect_agent_service_id" {
  description = "The service id of the prefect agent"
  value       = aws_ecs_service.prefect_agent_service.id
}

output "prefect_agent_execution_role_arn" {
  description = "The prefect agent execution role arn"
  value       = aws_iam_role.prefect_agent_execution_role.arn
}

output "prefect_agent_task_role_arn" {
  description = "The prefect agent task role arn"
  value       = var.agent_task_role_arn == null ? aws_iam_role.prefect_agent_task_role[0].arn : var.agent_task_role_arn
}

output "prefect_agent_security_group" {
  description = "The prefect security group id"
  value       = aws_security_group.prefect_agent.id
}

output "prefect_agent_cluster_name" {
  description = "The prefect cluster name"
  value       = aws_ecs_cluster.prefect_agent_cluster.name
}
// Here is where we are defining
// our Terraform settings
terraform {
  cloud {
    organization = "ZhareC"

    workspaces {
      name = "zoomcamp-workspaces"
    }
  }
}

terraform {
  required_providers {
    // The only required provider we need
    // is aws, and we want version 4.0.0
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }

  // This is the required version of Terraform
  required_version = "~> 1.3.7"
}

// Here we are configuring our aws provider. 
// We are setting the region to the region of 
// our variable "aws_region"
provider "aws" {
  region = var.aws_region
}

# Here we are creating an AWS Secrets Manager resource 
resource "aws_secretsmanager_secret" "prefect_api_key" {
  name = "prefect-api-key-${var.name}"
}

# Here we are creating an AWS secrets resource that will hold the secret value
resource "aws_secretsmanager_secret_version" "prefect_api_key_version" {
  secret_id = aws_secretsmanager_secret.prefect_api_key.id
  secret_string = var.prefect_api_key
}

resource "aws_iam_role" "prefect_agent_execution_role" {
  name = "prefect-agent-execution-role-${var.name}"

  assume_role_policy = jsonencode({
    Version = "2023-02-01"
    Statement = [
      {
        Action = "sts:assumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ssm-allow-read-prefect-api-key-${var.name}"
    policy = jsonencode({
      Version = "2023-02-01"
      Statement = [
        {
          Action = [
            "kms:Decrypt",
            "secretsmanager:GetSecretValue",
            "ssm:GetParamaters"
          ]
          Effect = "Allow"
          Resource = [
            aws_secretsmanager_secret.prefect_api_key.arn
          ]
        }
      ]
    })
  }
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role" "prefect_agent_task_role" {
  name = "prefect-agent-task-role-${var.name}"
  count = var.agent_task_role_arn == null ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2023-02-01"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-task.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "prefect-agent-allow-ecs-task-${var.name}"
    policy = jsonencode({
      Version = "2023-02-01"
      Statement = [
        {
          Action = [
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:GetAuthorizationToken",
            "ecr:GetDownloadUrlForLayer",
            "ecs:DeregisterTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:RunTask",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:GetLogStream",
            "logs:PutLogEvents"
          ]
          Effect = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "prefect_agent_log_group" {
  name = "prefect-agent-log-group-${var.name}"
  retention_in_days = var.agent_log_retention_in_days
}

resource "aws_security_group" "prefect_agent" {
  name = "prefect-agent-sg-${var.name}"
  description = "ECS Prefect Agent"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "https_outbound" {
  description = "HTTPS outbound"
  type = "egress"
  security_group_id = aws_security_group.prefect_agent.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_ecs_cluster" "prefect_agent_cluster" {
  name = "prefect-agent-${var.name}"
}

resource "aws_ecs_cluster_capacity_providers" "prefect_agent_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.prefect_agent_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "prefect_agent_task_definition" {
  family = "prefect-agent-${var.name}"
  cpu = var.agent_cpu
  memory = var.agent_memory

  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name = "prefect-agent-${var.name}"
      image = var.agent_image
      command = ["prefect", "agent", "start", "-q", var.agent_queue_name]
      cpu = var.agent_cpu
      memory = var.agent_memory
      environment = [
        {
          name = "PREFECT_API_URL"
          value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}"
        },
        {
          name = "EXTRA_PIP_PACKAGES"
          value = var.agent_extra_pip_packages
        }
      ]
      secrets = [
        {
          name = "PREFECT_API_KEY"
          valueFrom = var.agent_extra_pip_packages
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        option = {
          awslogs-group = aws_cloudwatch_log_group.prefect_agent_log_group.name
          awslogs-region = var.aws_region
          awslogs-stream-prefic = "prefect-agent-${var.name}"
        }
      }
  }
  ])
  execution_role_arn = aws_iam_role.prefect_agent_execution_role.arn
  task_role_arn = var.agent_task_role_arn == null ? aws_iam_role.prefect_agent_task_role[0].arn : var.agent_task_role_arn
}

resource "aws_ecs_service" "prefect_agent_service" {
  name = "prefect-agent-${var.name}"
  cluster = aws_ecs_cluster.prefect_agent_cluster.id
  desired_count = var.agent_desired_count
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.prefect_agent.id]
    assign_public_ip = true 
    subnets = var.agent_subnets
  }
  task_definition = aws_ecs_task_definition.prefect_agent_task_definition.arn
}
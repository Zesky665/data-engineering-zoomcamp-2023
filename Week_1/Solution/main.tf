terraform {
  cloud {
    organization = "ZhareC"

    workspaces {
      name = "example-workspace"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "prefect" {
  ami           = "ami-03e08697c325f02ab"
  instance_type = "t2.micro"
  key_name = "prefect"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_db_instance" "pg_db" {
  allocated_storage    = 5
  db_name              = "nyc_taxy_data"
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  username             = "db_user"
  password             = var.db_password
  skip_final_snapshot  = true

    tags = {
    Name = "nyc_taxi_data"
  }
}
provider "aws" {
  region = "ap-southeast-1"
}

# Removed duplicate variable declarations from main.tf

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"
  
  name = var.name
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = true

  tags = {
    Terraform  = "true"
    Environment = "pp"
  }
}

# S3 Bucket
resource "aws_s3_bucket" "my_s3_bucket_pp" {
  bucket = "my-s3bucket-pp"
}

# Define bucket policy if needed
resource "aws_s3_bucket_policy" "my_s3_bucket_policy_pp" {
  bucket = aws_s3_bucket.my_s3_bucket_pp.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = ["s3:GetObject"],
        Effect    = "Allow",
        Resource  = "${aws_s3_bucket.my_s3_bucket_pp.arn}/*",
        Principal = "*"
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "my_ecs_cluster_pp" {
  name = "my-ecs-cluster-pp"
}

# Fargate Service
resource "aws_ecs_task_definition" "my_fargate_task_pp" {
  family                   = "my-fargate-task-pp"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name  = "my-app"
      image = "nginx"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "my_fargate_service_pp" {
  name            = "my-fargate-service-pp"
  cluster         = aws_ecs_cluster.my_ecs_cluster_pp.id
  task_definition = aws_ecs_task_definition.my_fargate_task_pp.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.my_app_sg.id]
  }
}

# Security Group
resource "aws_security_group" "my_app_sg" {
  name        = "my-app-sg-pp"
  description = "Allow all inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Environment = "pp"
  }
}


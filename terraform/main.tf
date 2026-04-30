terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Needed to get current AWS account ID for ECR base URL output
data "aws_caller_identity" "current" {}

# ── Latest Amazon Linux 2023 AMI ─────────────────────────────────
# Fetched dynamically so Terraform always uses a current, supported AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── VPC ───────────────────────────────────────────────────────────
# All resources (Jenkins EC2, SonarQube EC2, EKS) live inside this VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # Required tags for EKS to discover subnets
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
}

# ── Security Group: Jenkins ───────────────────────────────────────
resource "aws_security_group" "jenkins" {
  name   = "${var.project_name}-jenkins-sg"
  vpc_id = module.vpc.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins UI + webhook endpoint
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── Security Group: SonarQube ─────────────────────────────────────
resource "aws_security_group" "sonarqube" {
  name   = "${var.project_name}-sonarqube-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube web UI
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── Jenkins EC2 ───────────────────────────────────────────────────
# Ansible will configure this after Terraform creates it
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.jenkins_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30  # GB — Jenkins workspace + Docker images need space
  }

  tags = { Name = "${var.project_name}-jenkins" }
}

# ── SonarQube EC2 ─────────────────────────────────────────────────
resource "aws_instance" "sonarqube" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.sonarqube_instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.sonarqube.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
  }

  tags = { Name = "${var.project_name}-sonarqube" }
}

# ── ECR Repositories ──────────────────────────────────────────────
# One repo per service — Jenkins tags images as ECR_URL/<service>:<build_number>
locals {
  services = [
    "user-service",
    "product-service",
    "order-service",
    "notification-service",
    "api-gateway",
    "frontend",
    "ai-service",
    "aiops-service",
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.services)

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Project = var.project_name }
}

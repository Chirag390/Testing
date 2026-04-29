variable "aws_region" {
  description = "AWS region to deploy everything"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used as a prefix for all resource names"
  type        = string
  default     = "devops-demo"
}

variable "jenkins_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "sonarqube_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "eks_node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "eks_node_desired" {
  type    = number
  default = 2
}

variable "eks_node_min" {
  type    = number
  default = 1
}

variable "eks_node_max" {
  type    = number
  default = 3
}

variable "key_pair_name" {
  description = "AWS EC2 key pair name for SSH access"
  type        = string
}

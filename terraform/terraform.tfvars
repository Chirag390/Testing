# Fill these in before running terraform apply
# key_pair_name must match an existing EC2 key pair in your AWS account
# Create one via: aws ec2 create-key-pair --key-name devops-key --query 'KeyMaterial' --output text > devops-key.pem

aws_region   = "us-east-1"
project_name = "devops-demo"
key_pair_name = "devops-key"

# Instance types (t3.medium = 2 vCPU / 4 GB RAM — minimum for Jenkins + SonarQube)
jenkins_instance_type   = "t3.medium"
sonarqube_instance_type = "t3.medium"
eks_node_instance_type  = "t3.medium"

# EKS node count
eks_node_desired = 2
eks_node_min     = 1
eks_node_max     = 3

output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 — use this for GitHub webhook and Ansible inventory"
  value       = aws_instance.jenkins.public_ip
}

output "sonarqube_public_ip" {
  description = "Public IP of SonarQube EC2 — paste into Jenkinsfile SONAR_HOST_URL"
  value       = aws_instance.sonarqube.public_ip
}

output "ecr_repository_urls" {
  description = "ECR URLs per service — for reference"
  value       = { for name, repo in aws_ecr_repository.services : name => repo.repository_url }
}

output "ecr_base_url" {
  description = "Base ECR URL — paste this as ECR_URL in your Jenkinsfile"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "eks_cluster_name" {
  description = "EKS cluster name — run: aws eks update-kubeconfig --name <this>"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

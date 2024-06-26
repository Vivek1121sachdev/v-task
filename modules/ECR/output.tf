output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
  description = "ECR repository url"
}

output "repository_name" {
  value = aws_ecr_repository.repo.name
  description = "ECR repository name"
}
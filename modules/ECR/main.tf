// ECR //
resource "aws_ecr_repository" "repo" {
  name                 = "v_task_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
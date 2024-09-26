# ECR repository
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.env}-ecr-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    "env" = "${var.env}-ecr-repo"
  }
}
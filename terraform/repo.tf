resource "aws_codecommit_repository" "app_repo" {
  repository_name = "devops-app"
  description     = "Infrastructure-as-Code demo project"
}

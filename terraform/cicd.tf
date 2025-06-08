module "cicd_pipeline" {
  source  = "cloudposse/codepipeline/aws"

  name      = "devops-pipeline"
  namespace = "dev"
  stage     = "prod"

  providers = {
    aws = aws
  }

  codecommit_repo_name = aws_codecommit_repository.app_repo.repository_name
  codecommit_branch     = "main"

  build_projects = [
    {
      name           = "build-deploy"
      buildspec_path = "buildspec.yml"
      image          = "aws/codebuild/standard:7.0"
      compute_type   = "BUILD_GENERAL1_SMALL"
      timeout        = 10
    }
  ]

  tags = {
    Purpose = "CI/CD pipeline from CodeCommit"
  }
}

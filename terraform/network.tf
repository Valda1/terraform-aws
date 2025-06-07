module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my-vpc"
  cidr   = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1" # Check for latest version

  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  egress_rules  = ["all-all"]
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  name = "alb"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [aws_security_group.alb_sg.id]

  enable_http = true

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name_prefix      = "app"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path                = "/"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  ]
}

module "ec2_asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = "asg"
  launch_template_name      = "web-lt"
  vpc_zone_identifier       = module.vpc.public_subnets
  target_group_arns         = [module.alb.target_group_arns[0]]
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2

  launch_template = {
    name_prefix   = "web-"
    image_id      = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    security_groups = [aws_security_group.ec2_sg.id]
    user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "Hello from $(hostname)" > /usr/share/nginx/html/index.html
              EOF
    )
  }
}

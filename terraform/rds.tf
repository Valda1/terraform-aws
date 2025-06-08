module "rds" {
    source = "terraform-aws-modules/rds/aws"

    identifier = "postgres"
    engine = "postgres"
    engine_version = "15"
    instance_class = "db.t3.micro"

    allocated_storage = 20
    storage_encrypted = true
    multi_az = true
    publicly_accessible = false

    name = "rds"
    username = 
    password = 
    port = 5432

    vpc_security_group_ids = [module.rds_sg.security_group_id]
    subnet_ids             = module.vpc.private_subnets

    maintenance_window     = "Mon:00:00-Mon:03:00"
    backup_window          = "03:00-06:00"

    skip_final_snapshot    = true
    deletion_protection    = false
}



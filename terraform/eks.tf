module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"

    cluster_name = "my-cluster-eks"
    cluster_version = "1.27"

    cluster_endpoint_public_access = true

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets #Worker nodes subnets
    #subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
    control_plane_subnet_ids = module.vpc.private_subnets

    #node_groups {
    eks_managed_node_groups = {
        default = {
            min_size = 1
            max_size = 3
            desired_size = 2
            instance_types = ["t2.micro"]
        }
    }
}
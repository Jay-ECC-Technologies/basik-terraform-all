####################################################
# AWS Configuration
####################################################

aws_region = "ap-south-1"

####################################################
# Environment
####################################################

project_name = "basik-eks"

environment = "production"

####################################################
# EKS Configuration
####################################################

cluster_name = "basik-eks-cluster-v135"

cluster_version = "1.35"

cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true

####################################################
# Existing VPC
####################################################

vpc_name = "basik-eks-vpc"

vpc_id = "vpc-0d25141645715b7e5"

####################################################
# Existing Subnets
####################################################

# private_subnet_ids = [
#   "subnet-06a80394172cb5462",
#   "subnet-0e50734a6dc56d546",
# ]

# public_subnet_ids = [
#   "subnet-0a66c6d68169389ba",
#   "subnet-0b02a7e18c9e86981",
# ]

# ####################################################
# # Existing Resources
# ####################################################

# use_existing_efs = true

# efs_file_system_id = "fs-xxxxxxxx"

# use_existing_route53 = false

# route53_zone_name = ""

# use_existing_acm = false

# acm_domain_name = ""

####################################################
# Common Tags
####################################################

tags = {

  Project     = "Basik"

  Environment = "Production"

  ManagedBy   = "Terraform"

  Owner       = "Expert Cloud Consulting"

}


velero_bucket_name = "velero-tec-k8s-backup"


####################################################
# Public Subnet
####################################################

public_subnet_cidr = "10.0.128.0/24"

####################################################
# Private Subnets
####################################################

private_subnet_az1_cidr = "10.0.129.0/24"

private_subnet_az2_cidr = "10.0.130.0/24"

private_subnet_az3_cidr = "10.0.131.0/24"
cluster_enabled_log_types = ["api", "audit", "authenticator"]

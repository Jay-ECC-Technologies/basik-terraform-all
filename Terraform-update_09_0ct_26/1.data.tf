/*****************************************************************************************
* File        : data.tf
* Description : Existing AWS Infrastructure Data Sources
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################
# Current AWS Account
#############################################

data "aws_caller_identity" "current" {}

#############################################
# Current AWS Region
#############################################

data "aws_region" "current" {}

#############################################
# Available Availability Zones
#############################################

data "aws_availability_zones" "available" {
  state = "available"
}

#############################################
# Existing VPC
#############################################

data "aws_vpc" "selected" {

  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }

}

#############################################
# Existing Private Subnets
#############################################

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.private_az1.id, aws_subnet.private_az2.id, aws_subnet.private_az3.id]
  }

}

#############################################
# Existing Public Subnets
#############################################

data "aws_subnets" "public" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.public.id]
  }

}

#######################################################
# EKS Add-on Versions
#######################################################

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = local.cluster_version
  most_recent        = true
}

# #############################################
# # Existing EFS (Optional)
# #############################################

# data "aws_efs_file_system" "efs" {

#   count = var.use_existing_efs ? 1 : 0

#   file_system_id = var.efs_file_system_id

# }

# #############################################
# # Existing ACM Certificate (Optional)
# #############################################

# data "aws_acm_certificate" "certificate" {

#   count = var.use_existing_acm ? 1 : 0

#   domain      = var.acm_domain_name
#   statuses    = ["ISSUED"]
#   most_recent = true

# }

# #############################################
# # Existing Route53 Hosted Zone (Optional)
# #############################################

# data "aws_route53_zone" "hosted_zone" {

#   count = var.use_existing_route53 ? 1 : 0

#   name         = var.route53_zone_name
#   private_zone = false

# }
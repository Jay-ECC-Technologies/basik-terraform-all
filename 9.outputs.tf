/*****************************************************************************************
* File        : outputs.tf
* Description : Terraform Outputs
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

####################################################
# Cluster Information
####################################################

output "cluster_name" {

  description = "Amazon EKS Cluster Name"

  value = module.eks.cluster_name

}

output "cluster_version" {

  description = "Kubernetes Version"

  value = module.eks.cluster_version

}

output "cluster_arn" {

  description = "Amazon EKS Cluster ARN"

  value = module.eks.cluster_arn

}

output "cluster_endpoint" {

  description = "Amazon EKS API Endpoint"

  value = module.eks.cluster_endpoint

}

####################################################
# Authentication
####################################################

output "cluster_certificate_authority_data" {

  description = "Cluster CA Certificate"

  value = module.eks.cluster_certificate_authority_data

  sensitive = true

}

output "oidc_provider" {

  description = "OIDC Issuer URL"

  value = module.eks.oidc_provider

}

output "oidc_provider_arn" {

  description = "OIDC Provider ARN"

  value = module.eks.oidc_provider_arn

}

####################################################
# Networking
####################################################

output "vpc_id" {

  description = "Existing VPC"

  value = data.aws_vpc.selected.id

}

output "private_subnets" {

  description = "Private Subnets"

  value = data.aws_subnets.private.ids

}

output "public_subnets" {

  description = "Public Subnets"

  value = data.aws_subnets.public.ids

}

output "cluster_security_group_id" {

  description = "Cluster Security Group"

  value = module.eks.cluster_security_group_id

}

output "node_security_group_id" {

  description = "Node Security Group"

  value = module.eks.node_security_group_id

}

####################################################
# KMS
####################################################

output "kms_key_arn" {

  description = "KMS Key ARN"

  value = aws_kms_key.eks.arn

}

####################################################
# Managed Node Groups
####################################################

output "managed_node_groups" {

  description = "EKS Managed Node Groups"

  value = keys(module.eks.eks_managed_node_groups)

}

####################################################
# AWS Load Balancer Controller
####################################################

output "lbc_iam_role_arn" {

  description = "AWS Load Balancer Controller IAM Role"

  value = module.aws_load_balancer_controller_irsa.iam_role_arn

}

####################################################
# Karpenter
####################################################

output "karpenter_controller_role_arn" {

  description = "Karpenter Controller IAM Role"

  value = module.karpenter_irsa.iam_role_arn

}

output "karpenter_node_role_arn" {

  description = "Karpenter Node IAM Role"

  value = aws_iam_role.karpenter_node.arn

}

output "karpenter_instance_profile" {

  description = "Karpenter Instance Profile"

  value = aws_iam_instance_profile.karpenter.name

}


output "public_subnet_id" {

  value = aws_subnet.public.id

}

output "private_subnet_ids" {

  value = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id,
    aws_subnet.private_az3.id
  ]

}
/*****************************************************************************************
* File        : locals.tf
* Description : Local Variables
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

locals {

  ####################################################
  # General Configuration
  ####################################################

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  ####################################################
  # Cluster Configuration
  ####################################################

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  ####################################################
  # Naming Convention
  ####################################################

  name_prefix = "${var.project_name}-${var.environment}"

  ####################################################
  # Standard Resource Tags
  ####################################################

  common_tags = merge(

    var.tags,

    {

      Project     = var.project_name
      Environment = var.environment
      Cluster     = var.cluster_name
      ManagedBy   = "Terraform"
      Terraform   = "true"
      Owner       = "Expert Cloud Consulting"

    }

  )



  ####################################################
  # node group configuration
  ####################################################
  eks_managed_node_groups = {
    private-nodes-eks-platform = {
      node_group_name            = "private-nodes-eks-platform"
      use_name_prefix            = false
      instance_types = ["t3a.medium"]
      ami_type       = var.node_ami_type
      disk_size      = var.node_disk_size
      min_size       = 1
      max_size       = 15
      desired_size   = 2
      iam_role_use_name_prefix = false
      iam_role_name            = "platform-ng-role"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 1
      }
    }

    private-nodes-eks-tec = {
      node_group_name            = "private-nodes-eks-tec"
      use_name_prefix            = false
      instance_types = ["t3a.medium"]
      ami_type       = var.node_ami_type
      disk_size      = var.node_disk_size
      min_size       = 1
      max_size       = 15
      desired_size   = 2
      iam_role_use_name_prefix = false
      iam_role_name            = "tec-ng-role"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 1
      }
    }

    private-nodes-eks-spartans = {
      node_group_name            = "private-nodes-eks-spartans"
      use_name_prefix            = false
      instance_types = ["t3a.medium"]
      ami_type       = var.node_ami_type
      disk_size      = var.node_disk_size
      min_size       = 1
      max_size       = 15
      desired_size   = 2
      iam_role_use_name_prefix = false
      iam_role_name            = "spartans-ng-role"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 1
      }
    }

  } 
}
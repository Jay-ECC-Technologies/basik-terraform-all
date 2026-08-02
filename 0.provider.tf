/*****************************************************************************************
* File        : providers.tf
* Description : Terraform Provider Configuration
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################
# AWS Provider
#############################################

provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {

      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Expert Cloud Consulting"
      Cluster     = var.cluster_name

    }

  }

}

#############################################
# EKS Authentication
#############################################

data "aws_eks_cluster_auth" "this" {

  name = module.eks.cluster_name

}

#############################################
# Kubernetes Provider
#############################################

provider "kubernetes" {

  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token

}

#############################################
# Helm Provider
#############################################

provider "helm" {

  kubernetes  {

    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token

  }

}
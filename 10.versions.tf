/*****************************************************************************************
* File        : versions.tf
* Description : Terraform Version & Provider Requirements
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

terraform {

  required_version = ">= 1.10.0"

  required_providers {

    # create AWS resources
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.52"
    }

    # manage Kubernetes resources
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    # manage Helm charts resources
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }

    # manage TLS resources (used for OIDC and cert-manager)
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    # manage time-related resources (EKS API readiness checks if needed)
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
    # manage random resources (used for generating random strings, passwords, etc.)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

  }

}
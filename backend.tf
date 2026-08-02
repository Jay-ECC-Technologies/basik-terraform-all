/*****************************************************************************************
* File        : backend.tf
* Description : Remote Backend Configuration
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

terraform {

  backend "s3" {

    # Existing Terraform State Bucket
    bucket = "basik-eks-state-bucket"

    # New independent state file for EKS v1.35
    key = "terraform-aws-eks-v135.tfstate"

    # AWS Region
    region = "ap-south-1"

    # State Locking
    dynamodb_table = "terraform-state"

    # # Encrypt state file at rest
    # encrypt = true

  }

}
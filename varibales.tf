/*****************************************************************************************
* File        : variables.tf
* Description : Input Variables
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################
# AWS Configuration
#############################################

variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used for tagging AWS resources."
  type        = string
  default     = "basik-eks-v135"
}

#############################################
# EKS Configuration
#############################################

variable "cluster_name" {
  description = "Name of the new Amazon EKS cluster."
  type        = string
  default     = "basik-eks-cluster-v135"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the Kubernetes API server."
  type        = bool
  default     = true
}
# current cluster only have public access enabled, so we will keep it true for now. If we want to enable private access, we can set it to false and enable private access in the cluster configuration. 
variable "cluster_endpoint_private_access" {
  description = "Enable private access to the Kubernetes API server."
  type        = bool
  default     = true
}

variable "cluster_enabled_log_types" {
  description = "Control plane logs to enable."
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

#############################################
# Existing Network Configuration
#############################################

variable "vpc_name" {
  description = "Existing VPC name."
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

# variable "private_subnet_ids" {
#   description = "Existing private subnet IDs."
#   type        = list(string)
# }

# variable "public_subnet_ids" {
#   description = "Existing public subnet IDs."
#   type        = list(string)
# }

#############################################
# Node Group Configuration
#############################################

# variable "node_instance_types" {
#   description = "EC2 instance types for managed node groups."
#   type        = list(string)

#   default = [
#     "t2.medium"
#   ]
# }

variable "node_disk_size" {
  description = "Root EBS volume size (GiB)."
  type        = number
  default     = 10 # based on current cluster configuration, we can increase it if needed.
}

variable "node_ami_type" {
  description = "AMI type for managed node groups."
  type        = string
  default     = "AL2023_x86_64_STANDARD" # based on current cluster configuration, we can change it if needed.
}

#############################################
# Platform Node Group
#############################################

# variable "platform_desired_size" {
#   description = "Desired number of platform nodes."
#   type        = number
#   default     = 2 # based on current cluster configuration, we can increase it if needed.
# }

# variable "platform_min_size" {
#   description = "Minimum number of platform nodes."
#   type        = number
#   default     = 2 #based on current cluster configuration, we can increase it if needed.
# }

# variable "platform_max_size" {
#   description = "Maximum number of platform nodes."
#   type        = number
#   default     = 5 # based on current cluster configuration, we can increase it if needed.
# }

# #############################################
# # Compute Node Group
# #############################################

# variable "compute_desired_size" {
#   description = "Desired number of compute nodes."
#   type        = number
#   default     = 2
# }

# variable "compute_min_size" {
#   description = "Minimum number of compute nodes."
#   type        = number
#   default     = 2
# }

# variable "compute_max_size" {
#   description = "Maximum number of compute nodes."
#   type        = number
#   default     = 10
# }

#############################################
# Tags
#############################################

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)

  default = {
    ManagedBy = "Terraform"
  }
}

variable "velero_bucket_name" {
  type = string
}


####################################################
# Public Subnet
####################################################

variable "public_subnet_cidr" {

  description = "CIDR block for Public Subnet"

  type = string

}

####################################################
# Private Subnets
####################################################

variable "private_subnet_az1_cidr" {

  description = "CIDR block for Private Subnet AZ1"

  type = string

}

variable "private_subnet_az2_cidr" {

  description = "CIDR block for Private Subnet AZ2"

  type = string

}

variable "private_subnet_az3_cidr" {

  description = "CIDR block for Private Subnet AZ3"

  type = string

}
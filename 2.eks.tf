/*****************************************************************************************
* File        : eks.tf
* Description : Amazon EKS Cluster
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

####################################################
# Amazon EKS Cluster
####################################################

module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  ####################################################
  # General Configuration
  ####################################################

  name               = local.cluster_name
  kubernetes_version = local.cluster_version

  ####################################################
  # Networking
  ####################################################

  vpc_id     = data.aws_vpc.selected.id
  subnet_ids = [
  aws_subnet.private_az1.id,
  aws_subnet.private_az2.id,
  aws_subnet.private_az3.id
  ]

  ####################################################
  # API Endpoint
  ####################################################

  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access

  ####################################################
  # Cluster Logging
  ####################################################

  #enabled_log_types = var.cluster_enabled_log_types
  # Note: Currently, the cluster logging is disabled. We can enable it if needed.

  ####################################################
  # Secrets Encryption
  ####################################################

  encryption_config = {

    provider_key_arn = aws_kms_key.eks.arn

    resources = [
      "secrets"
    ]

  }

  ####################################################
  # IAM
  ####################################################

#   create_iam_role = false
#   iam_role_arn    = aws_iam_role.eks_cluster.arn
  create_iam_role = true
  # Note: Currently, the cluster IAM role is created by the module. We can use an existing IAM role if needed.

  ####################################################
  # Security Groups
  ####################################################

  create_security_group = true
  create_node_security_group    = true

  ####################################################
  # Cluster Security Group Rules
  ####################################################

  security_group_additional_rules = {

    ingress_all = {

      description = "Temporary - Allow all inbound"

      protocol = "-1"

      from_port = 0
      to_port   = 0

      type = "ingress"

      cidr_blocks = [
        "0.0.0.0/0"
      ]

    }

    egress_all = {

      description = "Allow all outbound"

      protocol = "-1"

      from_port = 0
      to_port   = 0

      type = "egress"

      cidr_blocks = [
        "0.0.0.0/0"
      ]

    }

  }

  ####################################################
  # Node Security Group Rules
  ####################################################

  node_security_group_additional_rules = {

    ingress_all = {

      description = "Temporary - Allow all inbound"

      protocol = "-1"

      from_port = 0
      to_port   = 0

      type = "ingress"

      cidr_blocks = [
        "0.0.0.0/0"
      ]

    }

    egress_all = {

      description = "Allow all outbound"

      protocol = "-1"

      from_port = 0
      to_port   = 0

      type = "egress"

      cidr_blocks = [
        "0.0.0.0/0"
      ]

    }

  }
  ####################################################
  # nodegroups
  ####################################################
  eks_managed_node_groups = local.eks_managed_node_groups
  
  ####################################################
  # Authentication Mode
  ####################################################
  authentication_mode = "API_AND_CONFIG_MAP"
  # current cluster only have CONFIG_MAP authentication mode enabled, so we will keep it for now. If we want to enable AWS_IAM authentication mode, we can set it to "API_AND_AWS_IAM" and enable AWS_IAM authentication in the cluster configuration.

  ####################################################
  # Cluster Creator Admin Permissions
  ####################################################
  enable_cluster_creator_admin_permissions = true

  ####################################################
  # Tags
  ####################################################

  tags = local.common_tags

  ####################################################
  # OIDC Provider
  ####################################################

  enable_irsa = true

  ####################################################
  # addons 
  ####################################################

  # addons = {
  #   coredns = {
  #     addon_version = data.aws_eks_addon_version.coredns.version
  #   }

  #   kube-proxy = {
  #     addon_version = data.aws_eks_addon_version.kube_proxy.version
  #   }

  #   vpc-cni = {
  #     addon_version = data.aws_eks_addon_version.vpc_cni.version
  #   }

  #   aws-ebs-csi-driver = {
  #     addon_version = data.aws_eks_addon_version.ebs_csi.version
  #   }
  # }

}
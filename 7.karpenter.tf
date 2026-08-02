# /*****************************************************************************************
# * File        : karpenter.tf
# * Description : Karpenter Installation
# * Project     : Basik EKS v1.35 Blue/Green Migration
# *****************************************************************************************/


/*****************************************************************************************
* File        : karpenter.tf
* Description : Karpenter Installation
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################################
# IRSA Role
#############################################################

module "karpenter_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.52"

  role_name = "${local.cluster_name}-karpenter-controller"

  attach_karpenter_controller_policy = true

  oidc_providers = {

    eks = {

      provider_arn = module.eks.oidc_provider_arn

      namespace_service_accounts = [

        "kube-system:karpenter"

      ]

    }

  }

  tags = local.common_tags

}

#############################################################
# Karpenter Node IAM Role
#############################################################

resource "aws_iam_role" "karpenter_node" {

  name = "${local.cluster_name}-karpenter-node"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

  tags = local.common_tags

}

#############################################################
# Worker Policies
#############################################################

resource "aws_iam_role_policy_attachment" "worker" {

  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "ecr" {

  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"

}

resource "aws_iam_role_policy_attachment" "cni" {

  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

#############################################################
# Instance Profile
#############################################################

resource "aws_iam_instance_profile" "karpenter" {

  name = "${local.cluster_name}-karpenter"

  role = aws_iam_role.karpenter_node.name

  tags = local.common_tags

}

#############################################################
# Helm Release
#############################################################

resource "helm_release" "karpenter" {

  name = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"

  chart = "karpenter"

  namespace = "kube-system"

  create_namespace = false

  wait = true

  timeout = 900

  values = [

    file("${path.module}/helm-values/karpenter-values.yaml")

  ]

  set {

    name = "settings.clusterName"

    value = module.eks.cluster_name

  }

  set {

    name = "settings.clusterEndpoint"

    value = module.eks.cluster_endpoint

  }

  set {

    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

    value = module.karpenter_irsa.iam_role_arn

  }

  depends_on = [

    module.eks

  ]

}
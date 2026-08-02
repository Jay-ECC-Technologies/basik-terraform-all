/*****************************************************************************************
* File        : addons.tf
* Description : Amazon EKS Managed Add-ons
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

####################################################
# Amazon VPC CNI
####################################################

resource "aws_eks_addon" "vpc_cni" {

  cluster_name = module.eks.cluster_name

  addon_name = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks
#   ]

  tags = local.common_tags

}

####################################################
# CoreDNS
####################################################

resource "aws_eks_addon" "coredns" {

  cluster_name = module.eks.cluster_name

  addon_name = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks
#   ]

  tags = local.common_tags

}

####################################################
# kube-proxy
####################################################

resource "aws_eks_addon" "kube_proxy" {

  cluster_name = module.eks.cluster_name

  addon_name = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks
#   ]

  tags = local.common_tags

}


#############################################################
# trust policy for EBS CSI Driver
#############################################################
data "aws_iam_policy_document" "ebs_csi_assume_role" {

  statement {

    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {

      type = "Federated"

      identifiers = [
        module.eks.oidc_provider_arn
      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]

    }

    condition {

      test = "StringEquals"

      variable = "${replace(module.eks.oidc_provider, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]

    }

  }

}
#############################################################
# iam role for EBS CSI Driver
#############################################################
resource "aws_iam_role" "ebs_csi" {

  name = "${local.cluster_name}-ebs-csi"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = local.common_tags

}

################################################################
# Attach EBS CSI Driver to EKS Cluster
################################################################
resource "aws_iam_role_policy_attachment" "ebs_csi" {

  role = aws_iam_role.ebs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}


####################################################
# Amazon EBS CSI Driver
####################################################
resource "aws_eks_addon" "ebs_csi" {

  cluster_name = module.eks.cluster_name

  service_account_role_arn = aws_iam_role.ebs_csi.arn

  addon_name = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks
#   ]

  tags = local.common_tags

}

####################################################
# Amazon EFS CSI
####################################################

resource "aws_eks_addon" "efs_csi" {

  cluster_name = module.eks.cluster_name

  addon_name = "aws-efs-csi-driver"

  service_account_role_arn = aws_iam_role.efs_csi.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     module.eks
#   ]

  tags = local.common_tags

}
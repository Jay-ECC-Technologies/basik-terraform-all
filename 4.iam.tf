# /*****************************************************************************************
# * File        : iam.tf
# * Description : IAM Roles for Amazon EKS
# * Project     : Basik EKS v1.35 Blue/Green Migration
# *****************************************************************************************/

# #############################################
# # Worker Node Policies
# #############################################

resource "aws_iam_policy" "velero" {
  name        = "${var.cluster_name}-velero-policy"
  description = "IAM Policy for Velero"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # S3 Bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          "arn:aws:s3:::${var.velero_bucket_name}"
        ]
      },

      # S3 Objects
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "arn:aws:s3:::${var.velero_bucket_name}/*"
        ]
      },

      # EC2 Snapshot Operations
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeInstances",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },

      # Restore Operations
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      }

    ]
  })
}

resource "aws_iam_role" "velero" {

  name = "${local.cluster_name}-velero-irsa"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = module.eks.oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:velero:velero-server"
            "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "velero" {

  role       = aws_iam_role.velero.name
  policy_arn = aws_iam_policy.velero.arn

}

/*****************************************************************************************
* File        : efs-csi-irsa.tf
* Description : IAM Role for Amazon EFS CSI Driver (IRSA)
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

####################################################
# Trust Policy
####################################################

data "aws_iam_policy_document" "efs_csi_assume_role" {

  statement {

    sid    = "AllowAssumeRoleWithWebIdentity"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

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
        "system:serviceaccount:kube-system:efs-csi-controller-sa"
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

####################################################
# IAM Role
####################################################

resource "aws_iam_role" "efs_csi" {

  name = "${local.cluster_name}-efs-csi"

  assume_role_policy = data.aws_iam_policy_document.efs_csi_assume_role.json

  tags = local.common_tags

}

####################################################
# AWS Managed Policy
####################################################

resource "aws_iam_role_policy_attachment" "efs_csi" {

  role = aws_iam_role.efs_csi.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"

}
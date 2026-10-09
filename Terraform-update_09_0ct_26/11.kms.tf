# Separate tracked key retained. Live EKS encryption uses module.eks.module.kms.
/*****************************************************************************************
* File        : kms.tf
* Description : AWS KMS Key for Amazon EKS Secrets Encryption
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################
# KMS Key
#############################################

resource "aws_kms_key" "eks" {

  description = "KMS key for ${local.cluster_name} Kubernetes Secrets encryption"

  deletion_window_in_days = 30

  enable_key_rotation = true

  lifecycle { prevent_destroy = true }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-kms-key"
    }
  )
}

#############################################
# KMS Alias
#############################################

resource "aws_kms_alias" "eks" {

  name = "alias/${local.cluster_name}"

  target_key_id = aws_kms_key.eks.key_id

}
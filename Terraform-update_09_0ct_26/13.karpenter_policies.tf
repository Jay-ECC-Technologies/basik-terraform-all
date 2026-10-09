resource "aws_iam_policy" "karpenter_eks_integration" {
  name = "basik-eks-cluster-v135-karpenter-eks-integration"
  path = "/"
  description = "Karpenter v1.14 EKS cluster discovery permissions"
  policy = file("${path.module}/iam-policies/eks_integration.json")
  tags = {
  "Project": "basik-eks",
  "Owner": "Expert Cloud Consulting",
  "ManagedBy": "Terraform",
  "Terraform": "true",
  "Cluster": "basik-eks-cluster-v135",
  "Environment": "production",
  "aws-apn-id": "a5ds2cjuxeo5p25u8p6v6zy0j"
}
}

resource "aws_iam_policy" "karpenter_iam_integration" {
  name = "basik-eks-cluster-v135-karpenter-iam-integration"
  path = "/"
  description = "Karpenter v1.14 IAM instance profile management permissions"
  policy = file("${path.module}/iam-policies/iam_integration.json")
  tags = {
  "Project": "basik-eks",
  "Owner": "Expert Cloud Consulting",
  "ManagedBy": "Terraform",
  "Terraform": "true",
  "Cluster": "basik-eks-cluster-v135",
  "Environment": "production",
  "aws-apn-id": "a5ds2cjuxeo5p25u8p6v6zy0j"
}
}

resource "aws_iam_policy" "karpenter_node_lifecycle" {
  name = "basik-eks-cluster-v135-karpenter-node-lifecycle"
  path = "/"
  description = "Karpenter v1.14 EC2 node and launch template lifecycle permissions"
  policy = file("${path.module}/iam-policies/node_lifecycle.json")
  tags = {
  "Project": "basik-eks",
  "Owner": "Expert Cloud Consulting",
  "ManagedBy": "Terraform",
  "Terraform": "true",
  "Cluster": "basik-eks-cluster-v135",
  "Environment": "production",
  "aws-apn-id": "a5ds2cjuxeo5p25u8p6v6zy0j"
}
}

resource "aws_iam_policy" "karpenter_resource_discovery" {
  name = "basik-eks-cluster-v135-karpenter-resource-discovery"
  path = "/"
  description = "Karpenter v1.14 read-only AWS resource discovery permissions"
  policy = file("${path.module}/iam-policies/resource_discovery.json")
  tags = {
  "Project": "basik-eks",
  "Owner": "Expert Cloud Consulting",
  "ManagedBy": "Terraform",
  "Terraform": "true",
  "Cluster": "basik-eks-cluster-v135",
  "Environment": "production",
  "aws-apn-id": "a5ds2cjuxeo5p25u8p6v6zy0j"
}
}

resource "aws_iam_policy" "karpenter_zonal_shift" {
  name = "basik-eks-cluster-v135-karpenter-zonal-shift"
  path = "/"
  description = "Karpenter v1.14 ARC Zonal Shift read permissions"
  policy = file("${path.module}/iam-policies/zonal_shift.json")
  tags = {
  "Project": "basik-eks",
  "Owner": "Expert Cloud Consulting",
  "ManagedBy": "Terraform",
  "Terraform": "true",
  "Cluster": "basik-eks-cluster-v135",
  "Environment": "production",
  "aws-apn-id": "a5ds2cjuxeo5p25u8p6v6zy0j"
}
}

resource "aws_iam_role_policy_attachment" "karpenter_v114_controller" {
  for_each = {
    eks_integration = aws_iam_policy.karpenter_eks_integration.arn
    iam_integration = aws_iam_policy.karpenter_iam_integration.arn
    node_lifecycle = aws_iam_policy.karpenter_node_lifecycle.arn
    resource_discovery = aws_iam_policy.karpenter_resource_discovery.arn
    zonal_shift = aws_iam_policy.karpenter_zonal_shift.arn
  }
  role = "${local.cluster_name}-karpenter-controller"
  policy_arn = each.value
  depends_on = [module.karpenter_irsa]
}

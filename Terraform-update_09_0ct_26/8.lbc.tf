# Chart version verified; full Helm values still require plan review.
# /*****************************************************************************************
# * File        : lbc.tf
# * Description : AWS Load Balancer Controller
# * Project     : Basik EKS v1.35 Blue/Green Migration
# *****************************************************************************************

/*****************************************************************************************
* File        : lbc.tf
* Description : AWS Load Balancer Controller
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

#############################################################
# IAM Role for AWS Load Balancer Controller
#############################################################

module "aws_load_balancer_controller_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.52"

  role_name = "${local.cluster_name}-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {

    eks = {

      provider_arn = module.eks.oidc_provider_arn

      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]

    }

  }

  tags = local.common_tags

}

#############################################################
# AWS Load Balancer Controller
#############################################################

resource "helm_release" "aws_load_balancer_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"
  version = "3.4.3"

  namespace = "kube-system"

  create_namespace = false

  wait = true

  timeout = 600

  values = [

    file("${path.module}/helm-values/aws-load-balancer-controller-values.yaml")

  ]

  set {

    name = "clusterName"

    value = module.eks.cluster_name

  }

  set {

    name = "serviceAccount.create"

    value = "true"

  }

  set {

    name = "serviceAccount.name"

    value = "aws-load-balancer-controller"

  }

  set {

    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"

    value = module.aws_load_balancer_controller_irsa.iam_role_arn

  }

  depends_on = [

    module.eks

  ]

}
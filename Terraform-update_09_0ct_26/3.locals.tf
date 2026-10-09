locals {
  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  name_prefix     = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project = var.project_name
    Environment = var.environment
    Cluster = var.cluster_name
    ManagedBy = "Terraform"
    Terraform = "true"
    Owner = "Expert Cloud Consulting"
    aws-apn-id = "a5ds2cjuxeo5p25u8p6v6zy0j"
  })
  eks_managed_node_groups = {
    private-nodes-eks-platform = {
      node_group_name = "private-nodes-eks-platform"
      use_name_prefix = false
      instance_types = ["t3a.2xlarge"]
      ami_type = "AL2023_x86_64_STANDARD"
      capacity_type = "ON_DEMAND"
      subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
      min_size = 0
      max_size = 5
      desired_size = 5
      labels = { role = "platform" }
      iam_role_use_name_prefix = false
      iam_role_name = "platform-ng-role"
      # Match observed disks. Confirm all launch-template fields against live state.
      disk_size = 40
      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 40
            volume_type = "gp3"
            iops = 3000
            throughput = 125
            encrypted = false
            delete_on_termination = true
          }
        }
      }
      launch_template_version = "3"
      update_launch_template_default_version = false
      metadata_options = {
        http_endpoint = "enabled"
        http_tokens = "optional"
        http_put_response_hop_limit = 1
      }
      update_config = {
        max_unavailable = 1
      }
    }
    private-nodes-eks-tec = {
      node_group_name = "private-nodes-eks-tec"
      use_name_prefix = false
      instance_types = ["t3a.medium"]
      ami_type = "AL2023_x86_64_STANDARD"
      capacity_type = "ON_DEMAND"
      subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
      min_size = 0
      max_size = 5
      desired_size = 5
      labels = { role = "tec" }
      iam_role_use_name_prefix = false
      iam_role_name = "tec-ng-role"
      # Current launch template has no explicit disk mapping; preserve AMI defaults.
      launch_template_version = "2"
      update_launch_template_default_version = false
      metadata_options = {
        http_endpoint = "enabled"
        http_tokens = "optional"
        http_put_response_hop_limit = 1
      }
      update_config = {
        max_unavailable_percentage = 33
      }
    }
    private-nodes-eks-spartans = {
      node_group_name = "private-nodes-eks-spartans"
      use_name_prefix = false
      instance_types = ["t3a.medium"]
      ami_type = "AL2023_x86_64_STANDARD"
      capacity_type = "ON_DEMAND"
      subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
      min_size = 0
      max_size = 4
      desired_size = 4
      labels = { role = "spartans" }
      iam_role_use_name_prefix = false
      iam_role_name = "spartans-ng-role"
      # Current launch template has no explicit disk mapping; preserve AMI defaults.
      launch_template_version = "2"
      update_launch_template_default_version = false
      metadata_options = {
        http_endpoint = "enabled"
        http_tokens = "optional"
        http_put_response_hop_limit = 1
      }
      update_config = {
        max_unavailable_percentage = 33
      }
    }
  }
}

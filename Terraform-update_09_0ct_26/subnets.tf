/*****************************************************************************************
* File        : subnets.tf
* Description : Create 1 Public and 3 Private Subnets
* Project     : Basik EKS v1.35 Blue/Green Migration
*****************************************************************************************/

####################################################
# Public Subnet
####################################################

resource "aws_subnet" "public" {

  vpc_id = data.aws_vpc.selected.id

  cidr_block = var.public_subnet_cidr

  availability_zone = "${var.aws_region}a"

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-public-subnet"

      "kubernetes.io/role/elb" = "1"

      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}

####################################################
# Private Subnet - AZ1
####################################################

resource "aws_subnet" "private_az1" {

  vpc_id = data.aws_vpc.selected.id

  cidr_block = var.private_subnet_az1_cidr

  availability_zone = "${var.aws_region}a"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-private-subnet-az1"

      "kubernetes.io/role/internal-elb" = "1"

      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}

####################################################
# Private Subnet - AZ2
####################################################

resource "aws_subnet" "private_az2" {

  vpc_id = data.aws_vpc.selected.id

  cidr_block = var.private_subnet_az2_cidr

  availability_zone = "${var.aws_region}b"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-private-subnet-az2"

      "kubernetes.io/role/internal-elb" = "1"

      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}

####################################################
# Private Subnet - AZ3
####################################################

resource "aws_subnet" "private_az3" {

  vpc_id = data.aws_vpc.selected.id

  cidr_block = var.private_subnet_az3_cidr

  availability_zone = "${var.aws_region}c"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.cluster_name}-private-subnet-az3"

      "kubernetes.io/role/internal-elb" = "1"

      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    }
  )
}
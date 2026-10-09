# Existing BASIK state location; S3 provides both storage and native locking.
terraform {
  backend "s3" {
    bucket       = "basik-eks-state-bucket"
    key          = "terraform-aws-eks-v135.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

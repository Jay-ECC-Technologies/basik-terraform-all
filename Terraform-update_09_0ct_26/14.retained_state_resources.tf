# Retention-only declarations for resources already in state but absent from old source.
# ignore_changes freezes their configuration; prevent_destroy rejects replacement/deletion.
# Recover complete original settings before removing these lifecycle protections.

resource "aws_efs_access_point" "elastic_logging_0" {
  file_system_id = aws_efs_file_system.elastic_logging.id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

resource "aws_efs_access_point" "elastic_logging_1" {
  file_system_id = aws_efs_file_system.elastic_logging.id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

resource "aws_efs_access_point" "traefik" {
  file_system_id = aws_efs_file_system.traefik.id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

resource "aws_efs_file_system" "elastic_logging" {
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

resource "aws_efs_file_system" "traefik" {
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_efs_mount_target" "retained_elastic_logging_az1" {
  mount_target_id = "fsmt-01df40356926d4ee0"
}

resource "aws_efs_mount_target" "elastic_logging_az1" {
  file_system_id = aws_efs_file_system.elastic_logging.id
  subnet_id = data.aws_efs_mount_target.retained_elastic_logging_az1.subnet_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_efs_mount_target" "retained_elastic_logging_az2" {
  mount_target_id = "fsmt-0911e0b7c4a6cc94a"
}

resource "aws_efs_mount_target" "elastic_logging_az2" {
  file_system_id = aws_efs_file_system.elastic_logging.id
  subnet_id = data.aws_efs_mount_target.retained_elastic_logging_az2.subnet_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_efs_mount_target" "retained_traefik_az1" {
  mount_target_id = "fsmt-04424071fabbad9cb"
}

resource "aws_efs_mount_target" "traefik_az1" {
  file_system_id = aws_efs_file_system.traefik.id
  subnet_id = data.aws_efs_mount_target.retained_traefik_az1.subnet_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_efs_mount_target" "retained_traefik_az2" {
  mount_target_id = "fsmt-02d1ab37378f6236a"
}

resource "aws_efs_mount_target" "traefik_az2" {
  file_system_id = aws_efs_file_system.traefik.id
  subnet_id = data.aws_efs_mount_target.retained_traefik_az2.subnet_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_security_group" "retained_efs_elastic_logging" {
  id = "sg-0902791582b1dc9e7"
}

resource "aws_security_group" "efs_elastic_logging" {
  name = data.aws_security_group.retained_efs_elastic_logging.name
  description = data.aws_security_group.retained_efs_elastic_logging.description
  vpc_id = data.aws_security_group.retained_efs_elastic_logging.vpc_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

data "aws_security_group" "retained_efs_traefik" {
  id = "sg-00538764a66034e20"
}

resource "aws_security_group" "efs_traefik" {
  name = data.aws_security_group.retained_efs_traefik.name
  description = data.aws_security_group.retained_efs_traefik.description
  vpc_id = data.aws_security_group.retained_efs_traefik.vpc_id
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id = data.aws_vpc.selected.id
  service_name = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"
  lifecycle {
    ignore_changes = all
    prevent_destroy = true
  }
}

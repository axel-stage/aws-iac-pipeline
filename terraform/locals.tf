##############################################################################
# locals

locals {
  name = "${var.project_name}-${var.environment}"

  az_a = element(data.aws_availability_zones.available.names, 0)
  az_b = element(data.aws_availability_zones.available.names, 1)

  subnets = cidrsubnets(var.vpc_cidr_block, 8, 8)
}

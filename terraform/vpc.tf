###############################################################################
# local

locals {
  az_a = element(data.aws_availability_zones.available.names, 0)
  az_b = element(data.aws_availability_zones.available.names, 1)
}

###############################################################################
# vpc

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-${var.environment}-igw"
  }
}

###############################################################################
# subnet

resource "aws_subnet" "public_az_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets, 0)
  availability_zone       = local.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${var.environment}-subnet-public-${local.az_a}"
  }
}

###############################################################################
# routing

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-${var.environment}-public-rt"
  }
}
resource "aws_route_table_association" "public_az_a" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

###############################################################################
# endpoints

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.region}.s3"

  route_table_ids = [aws_route_table.public.id]

  tags = {
    Name = "${var.project}-${var.environment}-s3-vpc-endpoint"
  }
}

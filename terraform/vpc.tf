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

###############################################################################
# security groups

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress {
    description = "Allow all internal TCP and UDP"
    self        = true
    protocol    = -1
    from_port   = 0
    to_port     = 0
  }

  egress {
    description = "Allow all external TCP and UDP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-default-sg"
  }
}

resource "aws_security_group" "ubuntu" {
  name        = "${var.project}-${var.environment}-ubuntu-sg"
  description = "Security group for EC2 ubuntu instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Database access from my IP"
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = ["${data.external.local_public_ip.result.ipv4}/32"]
  }

  ingress {
    description = "SSH access from my IP"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${data.external.local_public_ip.result.ipv4}/32"]
  }

  egress {
    description = "Allow all external TCP and UDP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-ubuntu-sg"
  }
}
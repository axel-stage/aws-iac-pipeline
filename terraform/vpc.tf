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
    Name = "${local.name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_eip" "bastion" {
  domain = "vpc"

  tags = {
    Name = "${local.name}-eip-bastion"
  }
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_eip" "public_az_a" {
  domain = "vpc"

  tags = {
    Name = "${local.name}-eip-natgw"
  }
}

resource "aws_nat_gateway" "public_az_a" {
  allocation_id     = aws_eip.public_az_a.id
  subnet_id         = aws_subnet.public_az_a.id
  availability_mode = "zonal"

  tags = {
    Name = "${local.name}-natgw-public-${local.az_a}"
  }

  depends_on = [aws_internet_gateway.this]
}

###############################################################################
# subnet

resource "aws_subnet" "public_az_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(local.subnets, 0)
  availability_zone       = local.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-subnet-public-${local.az_a}"
  }
}

resource "aws_subnet" "private_az_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(local.subnets, 1)
  availability_zone       = local.az_a
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}-subnet-private-${local.az_a}"
  }
}

###############################################################################
# routing

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name}-rt-public"
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

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name}-rt-private"
  }
}
resource "aws_route_table_association" "private_az_a" {
  subnet_id      = aws_subnet.private_az_a.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.public_az_a.id
  destination_cidr_block = "0.0.0.0/0"
}

###############################################################################
# network load balancer

resource "aws_lb" "nlb" {
  name               = "${local.name}-nlb"
  internal           = false
  load_balancer_type = "network"

  subnets = [
    aws_subnet.public_az_a.id,
  ]

  security_groups = [
    aws_security_group.nlb.id,
  ]

  # Enable cross-zone load balancing for even distribution
  enable_cross_zone_load_balancing = false
  # Enable deletion protection for production
  enable_deletion_protection = false

  tags = {
    Name = "${local.name}-nlb"
  }
}

# resource "aws_lb_target_group" "ssh" {
#   name        = "${local.name}-tg-nlb-ssh"
#   vpc_id      = aws_vpc.this.id
#   protocol    = "TCP"
#   port        = 22
#   target_type = "instance"

#   health_check {
#     enabled             = true
#     protocol            = "TCP"
#     port                = "traffic-port"
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     interval            = 30
#   }

#   # Connection draining timeout
#   deregistration_delay = 60

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "${local.name}-tg-nlb-ssh"
#   }
# }

# resource "aws_lb_target_group" "http" {
#   name        = "${local.name}-tg-nlb-http"
#   vpc_id      = aws_vpc.this.id
#   protocol    = "TCP"
#   port        = 80
#   target_type = "instance"

#   health_check {
#     enabled             = true
#     protocol            = "HTTP"
#     path                = "/-/readiness" # /health
#     port                = "traffic-port"
#     healthy_threshold   = 3
#     unhealthy_threshold = 3
#     interval            = 30
#   }

#   # Connection draining timeout
#   deregistration_delay = 60

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "${local.name}-tg-nlb-http"
#   }
# }

resource "aws_lb_target_group" "app_8080" {
  name        = "${local.name}-tg-app"
  vpc_id      = aws_vpc.this.id
  protocol    = "TCP"
  port        = 8080
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
  }

  # Connection draining timeout
  deregistration_delay = 60

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.name}-tg-app"
  }
}

# resource "aws_lb_listener" "ssh" {
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = 22
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ssh.arn
#   }
# }

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_8080.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"

  # TLS certificate from ACM
  certificate_arn = aws_acm_certificate.this.arn

  # TLS security policy
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_8080.arn
  }
}

###############################################################################
# endpoints

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${data.aws_region.current.region}.s3"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${local.name}-s3-vpc-endpoint"
  }
}

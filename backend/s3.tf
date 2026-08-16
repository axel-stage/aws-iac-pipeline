###############################################################################
# s3

resource "aws_s3_bucket" "terraform" {
  bucket = "${var.project}-${var.environment}-terraform-backend"
  region = var.region

  # force_destroy = true

  tags = {
    Project     = var.project
    Environment = var.environment
    Name        = "Terraform backend state store"
    ProvisionBy = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_object" "terraform" {
  bucket = aws_s3_bucket.terraform.id
  key    = "infrastructure/terraform.tfstate"
}
###############################################################################
# local

resource "random_string" "naming" {
  length  = 4
  upper   = false
  numeric = false
  special = false
}

locals {
  suffix = random_string.naming.result
}

###############################################################################
# s3 bucket

resource "aws_s3_bucket" "this" {
  bucket        = "${var.project}-${var.environment}-${local.suffix}"
  force_destroy = var.force_destroy_bucket
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.bucket_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

###############################################################################
# s3 key

resource "aws_s3_object" "postgresql" {
  bucket = aws_s3_bucket.this.id
  key    = "postgresql/"
}


resource "aws_s3_object" "airflow" {
  bucket = aws_s3_bucket.this.id
  key    = "airflow/"
}
###############################################################################
# dynamodb

resource "aws_dynamodb_table" "terraform" {
  name   = "${var.project}-${var.environment}-TerraformLogTable"
  region = var.region

  billing_mode                = "PAY_PER_REQUEST"
  table_class                 = "STANDARD"
  deletion_protection_enabled = true

  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Description = "Terraform backend state log"
  }
}
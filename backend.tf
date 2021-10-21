# ------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-vpn-twsgo"
  # Preventing accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# ------------------------------------------------------------------------------
# CREATE THE DYNAMODB TABLE
# ------------------------------------------------------------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "tf-vpn-twsgo-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

# ------------------------------------------------------------------------------
# CREATE THE S3 AWS
# ------------------------------------------------------------------------------

# Save state to S3
# terraform {
#   backend "s3" {
#     bucket = "tf-state-vpn-twsgo"
#     key    = "twsgo/terraform.tfstate"
#     region = "eu-west-2"
#     dynamodb_table = "terraform-twsgo-lock"
#     encrypt        = true
#   }
# }

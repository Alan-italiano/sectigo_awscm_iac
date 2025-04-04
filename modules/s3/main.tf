resource "aws_s3_bucket" "sectigoBucket" {
  bucket = var.sectigo_bucket
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sectigoBucketRestrictions" {
  bucket = aws_s3_bucket.sectigoBucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

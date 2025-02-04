# Generate a random string for a unique bucket name
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create an S3 bucket
resource "aws_s3_bucket" "b338_bucket" {
  bucket = "cbz-frontend-project-${random_string.suffix.result}"

  tags = {
    Name = "StaticWebsiteBucket"
    env  = "dev"
  }
}

# Enable static website hosting (Corrected)
resource "aws_s3_bucket_website_configuration" "b338_website" {
  bucket = aws_s3_bucket.b338_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Disable Block Public Access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.b338_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set the bucket policy to allow public read access
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.b338_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.b338_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.example]
}

# Output the bucket's website endpoint
output "website_endpoint" {
  value       = aws_s3_bucket_website_configuration.b338_website.website_endpoint
  description = "The URL to access the static website"
}

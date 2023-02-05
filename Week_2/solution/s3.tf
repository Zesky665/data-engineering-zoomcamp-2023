resource "aws_s3_bucket" "prefect_bucket" {
  bucket = "zharec-prefect-bucket"
  tags = {
    Name = "Created using terraform"
  }
}

resource "aws_s3_bucket_acl" "prefect_bucket_acl"{
    bucket = aws_s3_bucket.prefect_bucket.id
    acl    = "private"
}
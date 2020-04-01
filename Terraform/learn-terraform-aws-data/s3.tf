resource "aws_s3_bucket" "tf-bucket" {
  bucket = "tf-bucket-bc8o42"
  acl    = "private"
  force_destroy = true
  tags = {
    Name = "tf-bucket-bc8o42"
  }
}
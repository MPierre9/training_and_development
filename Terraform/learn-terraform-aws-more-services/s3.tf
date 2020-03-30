resource "aws_s3_bucket" "b" {
  bucket = "tf-test-bucket-bc8o42"
  acl    = "private"

  tags = {
    Name = "tf-test-bucket-bc8o42"
  }
}
resource "aws_cloudwatch_log_group" "firehose-stream-log-group" {
  name = "/aws/kinesisfirehose/tf-stream-ingest"
}

resource "aws_cloudwatch_log_stream" "firehose-stream-log-stream" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose-stream-log-group.name
}
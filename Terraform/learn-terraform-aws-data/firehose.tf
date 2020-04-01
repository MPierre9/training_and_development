resource "aws_kinesis_firehose_delivery_stream" "tf-stream-ingest" {
  name        = "tf-stream-ingest"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.tf-bucket.arn
    prefix              = "game_data/year=!{timestamp:YYYY}"
    error_output_prefix = "game_data_error/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose-stream-log-group.name
      log_stream_name = aws_cloudwatch_log_stream.firehose-stream-log-stream.name
    }
    #data_format_conversion_configuration = "parquet"
    buffer_interval = 70

    processing_configuration {
      enabled = true


      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "firehose.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}



resource "aws_iam_policy" "firehose-delivery-role" {
  name        = "firehose-delivery-role-tf-stream-ingest"
  description = "Allows firehose to write to S3, log, and utilize Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "glue:GetTable",
        "glue:GetTableVersion",
        "glue:GetTableVersions"
      ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::tf-bucket-bc8o42",
        "arn:aws:s3:::tf-bucket-bc8o42/*",
        "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%",
        "arn:aws:s3:::%FIREHOSE_BUCKET_NAME%/*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:us-east-1:821777302053:function:firehose_lambda_1:$LATEST"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:us-east-1:821777302053:log-group:/aws/kinesisfirehose/tf-stream-ingest:log-stream:*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "kinesis:DescribeStream",
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:ListShards"
      ],
      "Resource": "arn:aws:kinesis:us-east-1:821777302053:stream/%FIREHOSE_STREAM_NAME%"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:kms:us-east-1:821777302053:key/%SSE_KEY_ID%"
      ],
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "kinesis.%REGION_NAME%.amazonaws.com"
        },
        "StringLike": {
          "kms:EncryptionContext:aws:kinesis:arn": "arn:aws:kinesis:%REGION_NAME%:821777302053:stream/%FIREHOSE_STREAM_NAME%"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-firehose-delivery-role" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose-delivery-role.arn
}

resource "aws_lambda_function" "lambda_processor" {
  filename      = var.lambda_func_path
  function_name = "firehose_lambda_1"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python2.7"
  timeout       = "70"
}

resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name        = "AWSLambdaBasicExecutionRole"
  description = "Provides write permissions to CloudWatch Logs."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}


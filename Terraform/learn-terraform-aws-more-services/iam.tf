# group definition
resource "aws_iam_group" "administrators" {
  name = "administrators"
}

resource "aws_iam_policy_attachment" "adminstrators-attach" {
  name       = "administrators-attach"
  groups     = [aws_iam_group.administrators.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Users
resource "aws_iam_user" "admin1" {
  name = "admin1"
}

resource "aws_iam_user" "admin2" {
  name = "admin2"
}

resource "aws_iam_group_membership" "administrators-users" {
  name = "adminstrators-users"
  users = [
    aws_iam_user.admin1.name,
    aws_iam_user.admin2.name
  ]
  group = aws_iam_group.administrators.name
}


# AWS IAM Role

resource "aws_iam_role" "s3-tf-test-bucket-role" {
  name               = "s3-tf-test-bucket-role"
  assume_role_policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
}
EOF
}

resource "aws_iam_instance_profile" "s3-tf-test-bucket-role-instanceprofile" {
  name = "s3-tf-test-bucket-role"
  role = aws_iam_role.s3-tf-test-bucket-role.name
}

resource "aws_iam_role_policy" "s3-tf-test-role-policy" {
  name   = "s3-tf-test-role-policy"
  role   = aws_iam_role.s3-tf-test-bucket-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::tf-test-bucket-bc8o42",
              "arn:aws:s3:::tf-test-bucket-bc8o42/*"
            ]
        }
    ]
}
EOF
}

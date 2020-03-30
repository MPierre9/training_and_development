resource "aws_instance" "example" {
  ami                    = var.amis[var.region]
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.terraform_learning_key_pair.key_name
  vpc_security_group_ids = ["${aws_security_group.terraform_learn_security_group.id}"]
  # VPC Subnet
  subnet_id = aws_subnet.main-public-1.id
  # user_data       = data.template_file.user_data_client.rendered
  user_data = data.template_cloudinit_config.cloudinit-example.rendered
  # role (allows use to read and write data to the s3-tf-test-bucket):
  iam_instance_profile = aws_iam_instance_profile.s3-tf-test-bucket-role-instanceprofile.name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.terraform_private_key)
    host        = self.public_ip
  }

  tags = {
    Name = "Terraform learning"
  }
}


# Extra EBS Volume
resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "us-east-1a"
  size              = 10
  type              = "gp2"
  tags = {
    Name = "Extra Volume Data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name  = "/dev/xvdh"
  volume_id    = aws_ebs_volume.ebs-volume-1.id
  instance_id  = aws_instance.example.id
  force_detach = "true" # https://github.com/terraform-providers/terraform-provider-aws/issues/4947
}



resource "aws_key_pair" "terraform_learning_key_pair" {
  key_name   = "terraform_learning_key_pair"
  public_key = file(var.terraform_public_key)
}

resource "aws_instance" "example" {
  ami             = var.amis[var.region]
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.terraform_learning_key_pair.key_name
  security_groups = ["${aws_security_group.terraform_learn_security_group.name}"]
  user_data       = data.template_file.user_data_client.rendered

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.terraform_private_key)
    host        = self.public_ip
  }

  tags = {
    Name = "Terraform learning"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo apachectl start",
      "sudo chkconfig --add httpd",
      "sudo chkconfig httpd on"
    ]
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

resource "aws_security_group" "terraform_learn_security_group" {
  name        = "terraform_learn_sec_group"
  description = "Security group to allow traffic from remote Terraform Cloud Backend"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from personal PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.terraform_ip.body)}/32"]
  }

  # ingress {
  #   description = "european ips"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = "${data.aws_ip_ranges.european_ec2.cidr_blocks}"
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow Terraform remote SSH"
  }
}

output "Your-Public-IP" {
  value = "${chomp(data.http.terraform_ip.body)}"
}

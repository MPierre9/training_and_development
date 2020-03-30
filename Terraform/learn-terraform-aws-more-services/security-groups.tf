resource "aws_security_group" "terraform_learn_security_group" {
  name        = "terraform_learn_sec_group"
  description = "Security group to allow traffic from remote Terraform Cloud Backend"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from personal PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.terraform_ip.body)}/32"]
  }

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
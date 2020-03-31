resource "aws_security_group" "terraform_learn_security_group" {
  name        = "terraform_learn_sec_group"
  description = "Security group to allow traffic from personal PC and for ELB to access instances over port 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from personal PC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.terraform_ip.body)}/32"]
  }

  ingress {
    description     = "Port 80 for ELB HTTP traffic"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform_learn_elb_security_group.id]
    cidr_blocks     = ["${chomp(data.http.terraform_ip.body)}/32"]
  }

  ingress {
    description     = "Port 8080 for ELB health checks"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.terraform_learn_elb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH and ELB Port 80"
  }
}

resource "aws_security_group" "terraform_learn_elb_security_group" {
  name        = "terraform_learn_elb_sec_group"
  description = "Security group for HTTP traffic from personal PC to ELB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP Traffic from my PC"
    from_port   = 80
    to_port     = 80
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
    Name = "Allow Port 80 from Personal PC"
  }
}
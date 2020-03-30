provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("C:/Users/Michael/.ssh/terraform.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = var.amis[var.region]
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Michael/.ssh/terraform")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo apachectl start",
      "sudo chkconfig --add httpd",
      "sudo chkconfig httpd on"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_dns} > ip_address.txt"
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

output "ip" {
  value = aws_eip.ip.public_ip
}

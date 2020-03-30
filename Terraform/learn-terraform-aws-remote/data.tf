data "http" "terraform_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ip_ranges" "european_ec2" {
  regions  = ["eu-west-1", "eu-central-1"]
  services = ["ec2"]
}

data "template_file" "user_data_client" {
  template = file("${var.template_path}/test_script.sh")
}
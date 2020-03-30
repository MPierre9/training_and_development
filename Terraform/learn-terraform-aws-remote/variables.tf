variable "region" {
  default = "us-east-1"
}

variable "amis" {
  default = {
    "us-east-1" = "ami-0fc61db8544a617ed",
    "us-east-2" = "ami-0e01ce4ee18447327"
  }
}

variable "terraform_public_key" {
  default = "terraform_pub_key"
}

variable "terraform_private_key" {
  default = "terraform_key"
}

variable "vpc_id" {
  default = "vpc-41fa523b"
}

variable "template_path" {
  default = "./template_scripts"
}
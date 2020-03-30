variable "region" {
    default = "us-east-1"
}

variable "amis" {
    default = {
        "us-east-1" = "ami-0fc61db8544a617ed",
        "us-east-2" = "ami-0e01ce4ee18447327"
    }
}
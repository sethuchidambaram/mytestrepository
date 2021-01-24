terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
}

locals {

	subnet=split(",",data.aws_ssm_parameter.test.value)

}

terraform {
  backend "s3" {
    bucket = "chidambaram"
    key    = "sethulab/ec2state"
    region = "ap-south-1"
  }
}






data "aws_ssm_parameter" "test" {
  name = "/vpn/subnets"

}

output "parametrevalue" { 
  value = local.subnet

}


resource "aws_instance" "example" {
  ami           = "ami-020edb5952484401d"
  instance_type = "t2.small"
  subnet_id=local.subnet[3]

	tags = {
	  Name = "hellovm"			
	}	

provisioner "local-exec" {
command = <<EOH
apt-get -y  install nginx
systemctl  status nginx
systemctl enable  nginx
EOH
}


}


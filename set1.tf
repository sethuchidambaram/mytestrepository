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


terraform {
  backend "s3"{ }
}



data "aws_ssm_parameter" "test" {
  name = "/vpn/subnets"

}


locals {
  instance-userdata = <<EOF
#!/bin/bash
apt-get -y  install nginx
systemctl  status nginx
systemctl enable  nginx
EOF
}


resource "aws_instance" "example1" {
  ami           = "ami-020edb5952484401d"
  instance_type = "t2.micro"
  subnet_id=element(split(",",data.aws_ssm_parameter.test.value),2)
  user_data = (local.instance-userdata)
	
	tags = {
	  Name = "ramakrishnavm"			
	}	

}






module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-sethuvpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  public_subnets  = ["10.0.23.0/24", "10.0.24.0/24", "10.0.25.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


data "aws_vpcs" "foo" {
  
depends_on = [module.vpc]
tags = {
    Name = "mytestvpn"
  }
}

output "subnet_cidr_blocks" {
  value = join(",",tolist(data.aws_vpcs.foo.ids))
}


data "aws_subnet_ids" "mynetwork" {
  vpc_id = join(",",tolist(data.aws_vpcs.foo.ids)) 

}

output "test3" {

value=[for i  in data.aws_subnet_ids.mynetwork.ids : i ]

}



terraform {
  backend "s3" {
    bucket = "chidambaram"
    key    = "sethulab/vpcstate"
    region = "ap-south-1"
  }
}

resource "aws_ssm_parameter" "krishna" {
  name  = "/vpn"
  type  = "StringList"
  value = join(",",tolist(data.aws_vpcs.foo.ids))

}

resource "aws_ssm_parameter" "sai" {
  name  = "/vpn/subnets"
  type  = "StringList"
  value = join("," ,[for i  in data.aws_subnet_ids.mynetwork.ids : i])
}


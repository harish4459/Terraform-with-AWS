# Terraform-with-AWS
A Terraform module to create an web app in AWS using VPC,EC2,LC,ASG.

# Usage
This module creates a VPC alongside a variety of related resources, including:

*Public and private subnets
*Public and private route tables
*Elastic IPs
*NAT Gateways
*An Internet Gateway
*A VPC Endpoint
*A bastion EC2 instance
*Launch configurations with Ec2 Instaces with EBS volumes with Nginx webapp installed on it.
*ASG 


# Example usage:

```
module "vpc" {
  source = "github.com/harish4459/Terraform-with-AWS"

  name = "Default"
  region = "us-east-1"
  key_name = "hector"
  cidr_block = "10.0.0.0/16"
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  bastion_ami = "ami-6869aa05"
  bastion_ebs_optimized = true
  bastion_instance_type = "t3.micro"

  project = "Something"
  environment = "Staging"
}
```

# Variables
*name - Name of the VPC (default: Default)
*region - Region of the VPC (default: us-east-1)
*key_name - EC2 Key pair name for the bastion
*cidr_block - CIDR block for the VPC (default: 10.0.0.0/16)
*public_subnet_cidr_blocks - List of public subnet CIDR blocks (default: ["10.0.0.0/24","10.0.2.0/24"])
*private_subnet_cidr_blocks - List of private subnet CIDR blocks (default: ["10.0.1.0/24", "10.0.3.0/24"])
*availability_zones - List of availability zones (default: ["us-east-1a", "us-east-1b"])
*bastion_ami - Bastion Amazon Machine Image (AMI) ID
*bastion_ebs_optimized - If true, the bastion instance will be EBS-optimized (default: false)
*bastion_instance_type - Instance type for bastion instance (default: t3.nano)

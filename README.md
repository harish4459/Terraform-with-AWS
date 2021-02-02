# Terraform-with-AWS
A Terraform module to create an web app in AWS using VPC,EC2,LC,ASG.

# Usage
This module creates a VPC alongside a variety of related resources, including:

* Public and private subnets
* Public and private route tables
* Security groups for App,Bastion instances
* Elastic IPs
* NAT Gateways
* An Internet Gateway
* A VPC Endpoint
* A bastion EC2 instance
* Launch configurations with Ec2 Instaces with EBS volumes with Nginx webapp installed on it.
* ASG 


# Example usage:

```
module "vpc" {
  source = "github.com/harish4459/Terraform-with-AWS"

  aws_access_key = "******************"
  aws_secret_key = "*******************"
  region = "us-west-1"
  key_name = "terraform"
  cidr_block = "10.0.0.0/16"
  private_subnet_cidr_block1 = "10.0.3.0/24"
  private_subnet_cidr_block2 = "10.0.4.0/24"
  public_subnet_cidr_block1 = "10.0.1.0/24"
  public_subnet_cidr_block2 = "10.0.2.0/24"
  availability_zones = ["us-west-1a", "us-west-1b"]
  bastion_ami = "ami-6869aa05"
  bastion_ssh_from = "127.0.0.1"
  public1_nat_ip = "******"
  public2_nat_ip = "******"

}
```

# Variables
* `region` - Region of the VPC (default: us-west-1)
* `Key_name` - EC2 Key pair name for the bastion
* `cidr_block` - CIDR block for the VPC (default: 10.0.0.0/16)
* `public_subnet_cidr_block1` -  public subnet CIDR block (default: "10.0.1.0/24")
* `public_subnet_cidr_block2` -  public subnet CIDR block (default: "10.0.2.0/24")
* `private_subnet_cidr_block1` - private subnet CIDR block (default:"10.0.3.0/24")
* `private_subnet_cidr_block2` - private subnet CIDR block (default:"10.0.4.0/24")
* `availability_zones` - List of availability zones (default: ["us-west-1a", "us-west-1b"])
* `bastion_ami` - Bastion Amazon Machine Image (AMI) ID
* `bastion_ssh_from` = From which ip you want ssh to bastion (default: 127.0.0.1)
* `public1_nat_ip` = Reserved NAT ip
* `public2_nat_ip` = Reserved NAT ip


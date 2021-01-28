variable "aws_access_key" {
    description = "access key"
    default = ""
}


variable "aws_secret_key" {
    description = "secret key"
    default = "

}


variable "region" {
  default     = "us-west-1"
  type        = string
  description = "Region of the VPC"
}


variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}



variable "public_subnet_cidr_block1" {
  description = "public subnet CIDR block1"
  default = "10.0.1.0/24"
}


variable "public_subnet_cidr_block2" {
  description = "public subnet CIDR block2"
  default = "10.0.2.0/24"

}

variable "private_subnet_cidr_block1" {
  description = "private subnet CIDR block1"
  default = "10.0.3.0/24"
}


variable "private_subnet_cidr_block2" {
  description = "private subnet CIDR block2"
  default = "10.0.4.0/24"

}

variable "availability_zones" {
  default     = ["us-west-1a", "us-west-1b"]
  type        = list
  description = "List of availability zones"
}


variable "bastion_ssh_from" {
  default = "127.0.0.1"
  type = string
}


variable "bastion_image"{

  default = "ami-01e24be29428c15b2"

}

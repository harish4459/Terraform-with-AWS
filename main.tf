provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region

}


resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}


# Subnets

resource "aws_subnet" "private1" {

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_block1
  availability_zone = var.availability_zones[0]

  depends_on = [
    aws_vpc.default
  ]

}


resource "aws_subnet" "private2" {

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnet_cidr_block2
  availability_zone = var.availability_zones[1]

  depends_on = [
    aws_vpc.default
  ]

}


resource "aws_subnet" "public1" {

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet_cidr_block1
  availability_zone = var.availability_zones[0]

  depends_on = [
    aws_vpc.default
  ]

}


resource "aws_subnet" "public2" {

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet_cidr_block2
  availability_zone = var.availability_zones[1]

  depends_on = [
    aws_vpc.default
  ]

}

# Security Groups

resource "aws_security_group" "alb_sg" {


  name        = "alb_sg"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_block1}"]
  }


  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_block2}"]
  }


  depends_on = [
    aws_vpc.default
  ]
}


resource "aws_security_group" "app_server_sg" {


  name        = "app_server_sg"
  description = "Allow all inbound traffic"
  vpc_id     = aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr_block1}"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr_block2}"]
  }



  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr_block1}"]
  }


  depends_on = [
    aws_vpc.default
  ]
}



resource "aws_security_group" "bastion_sg" {

  name        = "bastion_sg"
  description = "Allow all inbound traffic"
  vpc_id     = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_ssh_from}"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_block1}"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.private_subnet_cidr_block1}"]
  }


  depends_on = [
    aws_vpc.default
  ]
}



# configuartion and ASG for bastion

resource "aws_launch_configuration" "bastion_lc" {
  name_prefix   = "terraform-bastion-"
  image_id      = var.bastion_image
  instance_type = "t2.micro"
  key_name      = var.key_name
  security_groups = ["aws_security_group.bastion_sg.id"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_security_group.bastion_sg
  ]
}


resource "aws_autoscaling_group" "bastion"_asg {
  name                 = "terraform-bastion-asg"
  launch_configuration = aws_launch_configuration.bastion_lc.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier       = ["aws_subnet.public1.id"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.bastion_lc,
    aws_subnet.public1
  ]
}



# ALB,Target group, Listener

resource "aws_alb_target_group" "alb_target_group" {
  name     = "terra-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  depends_on = [
    "aws_vpc.default"
  ]
}

resource "aws_alb" "alb" {
  name               = "terra-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["aws_security_group.alb_sg.id"]
  subnets            = ["aws_subnet.public1.id","aws_subnet.public1.id"]

  enable_deletion_protection = false


  depends_on = [
    aws_security_group.alb_sg,
    aws_subnet.public1,
    aws_subnet.public2

  ]
}


resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    type             = "forward"
  }

  depends_on = [
    aws_alb.alb,
    aws_alb_target_group.alb_target_group
  ]
}



#internet gateway


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id

  depends_on = [
    aws_vpc.default
  ]
}



#route tables for lb


resource "aws_route_table" "public_route_table" {

  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [
    aws_vpc.default,
    aws_internet_gateway.igw
  ]
}

resource "aws_route_table_association" "public_route_table_assoc1" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_subnet.public1,
    aws_route_table.public_route_table,
  ]
}

resource "aws_route_table_association" "public_route_table_assoc2" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_subnet.public2,
    aws_route_table.public_route_table
  ]
}


#Nat Gateway


resource "aws_eip" "nat_1" {
  vpc                       = true
  associate_with_private_ip = var.public1_nat_ip
}

resource "aws_eip" "nat_2" {
  vpc                       = true
  associate_with_private_ip = var.public2_nat_ip
}

resource "aws_nat_gateway" "gw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public1.id

}

resource "aws_nat_gateway" "gw_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public2.id


}


#Route tables for appserver subnets

resource "aws_route_table" "app_route_table_1" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw_1.id
  }

  depends_on = [
    aws_vpc.default,
    aws_nat_gateway.gw_1
  ]
}

resource "aws_route_table_association" "app_route_table_assoc1" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.app_route_table_1.id

  depends_on = [
    aws_subnet.private1,
    aws_route_table.app_route_table_1
  ]
}

resource "aws_route_table" "app_route_table_2" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw_2.id
  }

  depends_on = [
    aws_vpc.default,
    aws_nat_gateway.gw_2
  ]
}

resource "aws_route_table_association" "app_route_table_assoc2" {
  count          = var.az_count
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.app_route_table_2.id

  depends_on = [
    aws_subnet.private2,
    aws_route_table.app_route_table_2
  ]
}


# launch config and ASG of app servers



data "aws_ami" "nginx-ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nginx-plus-ami-ubuntu-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # Canonical
}

resource "aws_launch_configuration" "lc" {
  name_prefix   = "terraform-lc-example-"
  image_id      = data.aws_ami.nginx-ubuntu.id
  instance_type = t2.micro
  key_name      = var.key_name
  security_groups = ["${aws_security_group.app_server_sg.id}"]
	
	
  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_security_group.app_server_sg
  ]
}

resource "aws_autoscaling_group" "app-asg1" {
  name                 = "terraform-asg-example-1"
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = 1
  desired_capacity 	   = 2		
  max_size             = 4
  vpc_zone_identifier       = ["${aws_subnet.private1.id}"]
  target_group_arns         = ["${aws_alb_target_group.alb_target_group.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.lc,
    aws_subnet.private1,
    aws_alb_target_group.alb_target_group
  ]
}

resource "aws_autoscaling_group" "app-asg2" {
  name                 = "terraform-asg-example-2"
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = 1
  desired_capacity 	   = 2	
  max_size             = 4
  vpc_zone_identifier       = ["${aws_subnet.private2.id}"]
  target_group_arns         = ["${aws_alb_target_group.alb_target_group.id}"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.lc,
    aws_subnet.private2,
    aws_alb_target_group.alb_target_group
  ]
}


output "alb_dns_name" {
	
	value = aws_alb.alb.dns_name
}

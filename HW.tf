#configure the aws provider
provider "aws" {
    region = "eu-central-1" 

    access_key = "AKIAYC54XFBPDNS556UO"
    secret_key = "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"
}

# defime the vvpc with the cide and a mask: 10.30.0.0/16
resource "aws_vpc" "fursa" {
  cidr_block = "10.30.0.0/16"
}

#creat a gate way for our vpc
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.fursa.id
  
}

#creat the route table and override the defult route table
resource "aws_route_table" "fursa-route-table" {
  vpc_id = aws_vpc.fursa.id

  route {
    cidr_block = "0.0.0.0/0" # IPv4
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0" #IPv6
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "fursa"
  }
}

#creat a subnet withn the vpc
resource "aws_subnet" "first_subnet" {
    vpc_id = aws_vpc.fursa.id
    cidr_block = "10.30.1.0/24"
    availability_zone = "eu-central-1a"

    tags = {
      Name = "first_subnet"
    }
  
}

#crat a second subnet
resource "aws_subnet" "second_subnet" {
    vpc_id = aws_vpc.fursa.id
    cidr_block = "10.30.10.0/24"
    availability_zone = "eu-central-1a"

    tags = {
      Name = "second_subnet"
    }
  
}

#crqt an aws instance
resource "aws_instance" "my_web_server" {
  ami = "ami-0502e817a62226e03"
  instance_type = "t2.micro"
  subnet_id  = aws_subnet.second_subnet.id
  availability_zone = "eu-central-1a"

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install docker.io -y
                chown ubuntu home/ubuntu
                EOF

  
}

#crat security group in our vpc
resource "aws_security_group" "allow_web" {
  name        = "allow_https"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.fursa.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description= "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
  
}

# the target group wich the load balncer will work on
resource "aws_lb_target_group" "trggr" {
  name = "target"
  port = 5000
  protocol = "HTTP"
  vpc_id = ws_vpc.fursa.id
}

# attach the target group with th load balancer

resource "aws_lb_target_group_attachment" "att" {
  
  target_group_arn = aws_lb_target_group.trggr.id
  target_id = aws_instance.my_web_server.id
  port = 5000
}

# crat a load balancer
resource "aws_lb" "my-lb" {
  name               = "my-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            =[ aws_subnet.first_subnet.id, aws_subnet.second_subnet.id]

  enable_deletion_protection = true


  tags = {
    Environment = "production"
  }
}


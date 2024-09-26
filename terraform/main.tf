# # VPC
# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Name = "main-vpc"
#   }
# }

# # Public subnet
# resource "aws_subnet" "public" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "ap-south-1a" # Change this to your desired AZ

#   tags = {
#     Name = "public-subnet"
#   }
# }

# # Private subnet
# resource "aws_subnet" "private" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "ap-south-1b" # Change this to your desired AZ

#   tags = {
#     Name = "private-subnet"
#   }
# }

# # Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main-igw"
#   }
# }

# # NAT Gateway
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "main-nat-gw"
#   }
# }

# # Elastic IP for NAT Gateway
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# # Route table for public subnet
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# # Route table for private subnet
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }

#   tags = {
#     Name = "private-route-table"
#   }
# }

# # Route table association for public subnet
# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }

# # Route table association for private subnet
# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }

# # Security group for EC2 instance
# resource "aws_security_group" "ec2" {
#   name        = "ec2-sg"
#   description = "Security group for EC2 instance"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Security group for ALB
# resource "aws_security_group" "alb" {
#   name        = "alb-sg"
#   description = "Security group for ALB"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # EC2 instance
# resource "aws_instance" "app" {
#   ami                    = "ami-0522ab6e1ddcc7055" # Amazon Linux 2 AMI (HVM), SSD Volume Type
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.ec2.id]
#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y nodejs npm git
#               git clone https://github.com/scotch-io/node-todo.git
#               cd node-todo
#               npm install
#               npm start
#               EOF

#   tags = {
#     Name = "app-server"
#   }
# }

# # Application Load Balancer
# resource "aws_lb" "main" {
#   name               = "main-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb.id]
#   subnets            = [aws_subnet.public.id, aws_subnet.private.id]
# }

# # ALB Target Group
# resource "aws_lb_target_group" "main" {
#   name     = "main-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main.id

#   health_check {
#     path                = "/"
#     healthy_threshold   = 2
#     unhealthy_threshold = 10
#   }
# }

# # ALB Listener
# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }

# # ALB Target Group Attachment
# resource "aws_lb_target_group_attachment" "main" {
#   target_group_arn = aws_lb_target_group.main.arn
#   target_id        = aws_instance.app.id
#   port             = 80
# }
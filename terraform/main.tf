resource "aws_key_pair" "nodejs_key" {
  key_name    = "nodejs_key"
  public_key = file("files/mykey.pem")
  }

resource "aws_vpc" "Node_VPC" {
  cidr_block           = var.vpc.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = var.vpc.enable_dns_hostnames
 
tags = {
    Name = var.vpc.name
}
}

resource "aws_subnet" "My_VPC_Public_Subnet" {
  vpc_id                  = aws_vpc.Node_VPC.id
  cidr_block              = var.vpc.public1_subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = var.vpc.availability_zone
tags = {
   Name = "My VPC Public Subnet 1"
}
}
resource "aws_subnet" "My_VPC_Public_Subnet2" {
  vpc_id                  = aws_vpc.Node_VPC.id
  cidr_block              = var.vpc.public2_subnet_cidr
  availability_zone       = "ap-south-1b"
tags = {
   Name = "My VPC Public Subnet 2"
}
}
resource "aws_subnet" "My_VPC_Private_Subnet" {
  vpc_id                  = aws_vpc.Node_VPC.id
  cidr_block              = var.vpc.private_subnet_cidr
  availability_zone       = var.vpc.availability_zone
tags = {
   Name = "My VPC Private Subnet"
}
}
resource "aws_internet_gateway" "Node_VPC_GW" {
 vpc_id = aws_vpc.Node_VPC.id
 tags = {
        Name = "My VPC Internet Gateway"
}
}
resource "aws_route_table" "Node_VPC_route_table" {
 vpc_id = aws_vpc.Node_VPC.id
 tags = {
        Name = "My VPC Route Table"
}
}

resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.Node_VPC_route_table.id
  destination_cidr_block =  "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Node_VPC_GW.id
}

resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Public_Subnet.id
  route_table_id = aws_route_table.Node_VPC_route_table.id
}
resource "aws_route_table_association" "My_VPC_association2" {
  subnet_id      = aws_subnet.My_VPC_Public_Subnet2.id
  route_table_id = aws_route_table.Node_VPC_route_table.id
}

resource "aws_security_group" "bastion_sg" {
  depends_on=[aws_subnet.My_VPC_Public_Subnet]
  name        = "bastion_sg"
  vpc_id      =  aws_vpc.Node_VPC.id

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
   vpc_id     = aws_vpc.Node_VPC.id
ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "lb_sg"
  }
}

 resource "aws_security_group" "node_sg" {
  depends_on  = [aws_subnet.My_VPC_Private_Subnet]
  name        = "node_sg"
  description = "allow ssh bositon inbound traffic"
  vpc_id      =  aws_vpc.Node_VPC.id

 ingress {
    description = "Only allow ssh from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups=[aws_security_group.bastion_sg.id]
 
 }
 
 ingress {
    description = "Allow http traffic from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups=[aws_security_group.lb_sg.id]
 
 }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks =  ["::/0"]
  }



  tags = {
    Name = "node_sg"
  }
}
resource "aws_eip" "gw_ip" {
  vpc              = true
  public_ipv4_pool = "amazon"
}

resource "aws_eip" "bastion_ip" {
  vpc = true
  public_ipv4_pool = "amazon"
}

resource "aws_nat_gateway" "node_gw" {
    depends_on=[aws_eip.gw_ip]
  allocation_id = aws_eip.gw_ip.id
  subnet_id     = aws_subnet.My_VPC_Public_Subnet.id
tags = {
    Name = "nat_gw"
  }
}

// Route table for Node app in private subnet

resource "aws_route_table" "private_subnet_route_table" {
      depends_on=[aws_nat_gateway.node_gw]
  vpc_id = aws_vpc.Node_VPC.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.node_gw.id
  }

  tags = {
    Name = "private_subnet_route_table"
  }
}


resource "aws_route_table_association" "private_subnet_route_table_association" {
  depends_on = [aws_route_table.private_subnet_route_table]
  subnet_id      = aws_subnet.My_VPC_Private_Subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

resource "aws_instance" "BASTION" {
  ami           = var.ec2.ami_id
  instance_type = var.ec2.instance_type
  subnet_id = aws_subnet.My_VPC_Public_Subnet.id
  vpc_security_group_ids = [ aws_security_group.bastion_sg.id ]
  key_name = var.ec2.pem_key
  user_data = file("templates/bastion_host.sh")
  tags = {
    Name = "bastionhost"
    }
}
resource "aws_instance" "node_ec2" {
  ami           = "ami-0f69bc5520884278e"
  instance_type = var.ec2.instance_type
  subnet_id = aws_subnet.My_VPC_Private_Subnet.id
  vpc_security_group_ids = [ aws_security_group.node_sg.id]
  key_name = var.ec2.pem_key

  tags = {
    Name = "node app"
    }
}

resource "aws_eip_association" "bastion_ip" {
  allocation_id = aws_eip.bastion_ip.id
  instance_id   = aws_instance.BASTION.id
}

resource "aws_alb" "node-lb" {
  name            = "node-lb"
  internal        = false
  security_groups = [aws_security_group.lb_sg.id]
  subnets         = [aws_subnet.My_VPC_Public_Subnet.id, aws_subnet.My_VPC_Public_Subnet2.id]
}

resource "aws_alb_target_group" "node-tg" {
  name     = "node-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Node_VPC.id
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.node-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.node-tg.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "lb-node" {
  target_group_arn = aws_alb_target_group.node-tg.arn
  target_id        = aws_instance.node_ec2.id
  port             = 80
}




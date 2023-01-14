vpc = {
  availability_zone    = "ap-south-1a"
  public1_subnet_cidr  = "192.168.0.0/24"
  public2_subnet_cidr  = "192.168.1.0/24"
  private_subnet_cidr  = "192.168.2.0/24"
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  name                 = "Node_VPC"
}

ec2 = {
  instance_type     = "t2.micro"
  ami_id            = "ami-0f69bc5520884278e"
  name              = "ppshein"
  volume_size       = 20
  volume_type       = "gp3"
  pem_key           = "nodejs_key"
}

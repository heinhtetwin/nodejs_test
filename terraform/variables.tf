variable "region" {
  type    = string
  default = "ap-south-1"
}

# declare Network layer attribute here
variable "vpc" {
  description = "The attribute of VPC information"
  type = object({
    name                 = string
    cidr_block           = string
    public1_subnet_cidr  = string
    public2_subnet_cidr  = string
    private_subnet_cidr  = string
    availability_zone    = string
    enable_dns_hostnames = bool
  })
}

# declare EC2 attribute here
variable "ec2" {
  description = "The attribute of EC2 information"
  type = object({
    name              = string
    ami_id            = string
    instance_type     = string
    pem_key           = string
  })
}
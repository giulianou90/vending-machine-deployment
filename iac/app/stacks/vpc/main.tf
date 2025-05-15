module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "5.18.1"
  name                 = "vpc-${var.environment}"
  cidr                 = var.cidr
  azs                  = var.availability_zones
  enable_nat_gateway   = true
  single_nat_gateway   = true 
  enable_dns_hostnames = true
  manage_default_route_table = false
  manage_default_network_acl = true

  default_route_table_name = "main"
  public_subnet_suffix = "public-${var.region}"
  
  private_subnets = [for i in range(2) : cidrsubnet(var.cidr, 2, i)]
  public_subnets  = [for j in range(2) : cidrsubnet(var.cidr, 2, j + 2)]

  vpc_tags = {
    Name = "vpc-${var.environment}"
    Environment = "${var.environment}"
  }
}
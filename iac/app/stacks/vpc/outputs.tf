output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}

output "private_subnets_id" {
  value = module.vpc.private_subnets
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}
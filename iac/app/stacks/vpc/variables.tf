variable "environment" {
  default = "prd"
}

variable "cidr" {
  description = "VPC Cidr Block"
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
  type = list(string)
}

variable "project_name" {
  description = "The name of the project"
  default = "project"
}
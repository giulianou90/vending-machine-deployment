data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.environment}"
    key    = "main/${data.aws_region.current.name}/${var.environment}/stacks/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}



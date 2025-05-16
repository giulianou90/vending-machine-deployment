data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.environment}"
    key    = "main/${data.aws_region.current.name}/${var.environment}/stacks/vpc/terraform.tfstate"
    region = data.aws_region.current.name
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    region = data.aws_region.current.name
    bucket   = "terraform-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.environment}"
    key    = "main/${data.aws_region.current.name}/${var.environment}/stacks/alb/terraform.tfstate"
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    region = data.aws_region.current.name
    bucket   = "terraform-state-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.environment}"
    key    = "main/${data.aws_region.current.name}/${var.environment}/stacks/ecr/terraform.tfstate"
  }
}

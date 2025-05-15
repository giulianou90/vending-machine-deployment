
locals {
  ecr_name = toset(var.ecr_name)
}

resource "aws_ecr_repository" "source_ecr" {
  for_each             = local.ecr_name
  name                 = "${each.key}/app"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }
}

resource "aws_ecr_repository_policy" "full_access_from_all_env" {
  for_each   = local.ecr_name
  repository = aws_ecr_repository.source_ecr[each.key].name
  policy     = <<EOF

  {
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "Full access to ECR",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${var.current_account_id}:root"
        ]
      },
      "Action": [
          "ecr:*"
      ]
    }
   ]
  }
  EOF
}
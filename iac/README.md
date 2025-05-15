# Terraspace Project

This is a Terraspace project. It contains code to provision Cloud infrastructure built with [Terraform](https://www.terraform.io/) and the [Terraspace Framework](https://terraspace.cloud/).

## Project Structure

```
vending-machine-deployment/iac
├── app/stacks
│   ├── alb/
│   ├── ecr/
│   ├── ecs/
│   ├── iam/
│   ├── vpc/
│   
├── config/terraform
│   ├── tfvars/
│   ├── backend.tf
│   ├── provider.tf
│   ├── root_data.tf
│   ├── root_variables.tf
├── .gitignore
└── README.md
```

## Deploy

To deploy all the infrastructure stacks:

    terraspace all up

To deploy individual stacks:

    terraspace up demo # where demo is app/stacks/demo

## Terrafile

To use more modules, add them to the [Terrafile](https://terraspace.cloud/docs/terrafile/).

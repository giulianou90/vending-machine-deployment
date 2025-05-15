variable "ecs_cluster_name" {
  type        = string
  default     = "vending-machine-cluster"
  description = "Solution name"
}

variable "container_name" {
  type        = string
  default     = "vending-machine"
  description = "Container name"
}

variable "service_name" {
  type        = string
  default     = "vending-machine"
  description = "ECS Service name"
}

variable "container_port" {
  type        = number
  default     = "80"
  description = "Container port"
}

variable "service_desired_count" {
  type        = number
  default     = 1
  description = "Amount of tasks for the service"
}

variable "asg_max_capacity" {
  type        = number
  default     = 1
  description = "max amount of tasks"
}

variable "asg_min_capacity" {
  type        = number
  default     = 1
  description = "min amount of tasks"
}

variable "enable_autoscaling" {
  type      = bool
  default = false
}

variable "container_definitions_path" {
  description = "The path of the container definitions json file."
  type        = string
  default = "./resources/service.json"
}

variable "task_name" {
  description = "The name of the task."
  type        = string
  default = "vending-machine"
}

variable "task_secret_name" {
  description = "The name of the environment variable to be added as a secret."
  type        = string
  default     = ""
}

variable "task_secret_parameter" {
  description = "The arn of the SSM parameter with the secret value of the environment variable."
  type        = string
  default     = ""
}

variable "container_cpu" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The number of cpu units to reserve for the container. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than the task-level cpu value"
  type        = string
  default     = 256 # 1024 = 1 vCPU 
}

variable "container_memory" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  type        = number
  default     = 1024 #  2 GB
}

variable "task_role_arn" {
  type = string
  default = ""
}

variable "tags" {
    default = ""
}

variable "environment" {
    default = "prd"
}
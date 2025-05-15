variable "ecr_name" {
  type        = any
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  default     = ["vending-machine"]
}

variable "scan_images_on_push" {
  type        = bool
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not (false)"
  default     = false
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
}

variable "current_account_id" {
    default = "483127353410"
}


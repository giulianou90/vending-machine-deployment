
variable "env" {
    type    = string
    default = "<%= expansion(':ENV') %>"
}

variable "account_id" {
  default = "483127353410"
}

variable "region" {
  default = "us-east-1"
}

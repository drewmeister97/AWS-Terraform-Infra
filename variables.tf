variable "region" {
  description = "The AWS region"
  default     = "ap-southeast-1"
  type        = string
}

variable "key_name" {
  default = "Key1"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  default     = true
}

variable "name" {
  description = "Name prefix for resources"
  default     = "my-vpc-pp"
}


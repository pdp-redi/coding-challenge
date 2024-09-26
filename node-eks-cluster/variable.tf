variable "env" {
  default = "test"
}

variable "region" {
  default = "ap-south-1"
}


variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "availability zones"
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnet CIDR values"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "env" {
  description = "Arsipa-Challenge"
  type        = string
}

variable "region" {
  description = "region"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR range"
  type        = string
}

variable "azs" {
  description = "availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "public subnet CIDR ranges"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "private subnet CIDR ranges"
  type        = list(string)
}

variable "domain_name" {
  description = "domain_name"
  type        = string
}

variable "container_port" {
  description = "container port"
  type        = number
}

variable "host_port" {
  description = "host port"
  type        = number
}

variable "fargate_cpu" {
  description = "host port"
  type        = number
}

variable "fargate_memory" {
  description = "host port"
  type        = number
}

variable "ecs_task_defination" {
  type        = string
  description = "ESC task defination"
}

variable "ecr_container" {
  type        = string
  description = "ECR container"
}


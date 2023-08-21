# variables.tf

variable "environment" {
  description = "prod"
}
variable "client_name" {
  description = "Client"
}

variable "public_subnet_names" {
  description = "Names of public subnets"
  type        = list(string)
  default     = ["public_subnet_1", "public_subnet_2"]
}
variable "private_subnet_names" {
  description = "Names of private subnets"
  type        = list(string)
  default     = ["private_subnet_1", "private_subnet_2"]
}
variable "services_subnet_names" {
  description = "Names of services subnets"
  type        = list(string)
  default     = ["services_subnet_1", "services_subnet_2"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  # default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "services_subnet_cidrs" {
  description = "List of CIDR blocks for services subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
  # default     = ["us-west-2a", "us-west-2b"]
}

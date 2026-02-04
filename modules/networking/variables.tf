variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "project_name" { default = "infrascore" }
variable "public_subnets_cidr" { 
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
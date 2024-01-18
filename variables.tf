variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/22"
}

variable "route_pub" {
  type = string
  default = "0.0.0.0/0"
}
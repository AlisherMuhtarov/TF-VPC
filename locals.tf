locals {
  public_subnet_cidrs = [
    for i in range(4) : cidrsubnet(var.vpc_cidr, 6, i)
  ]

  private_subnet_cidrs = [
    for i in range(4) : cidrsubnet(var.vpc_cidr, 6, (i +4))
  ]
}
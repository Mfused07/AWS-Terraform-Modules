# main.tf

module "my_vpc" {
  source = "./vpc_module"
  environment        = "prod"
  client_name = "Riverview"
  vpc_cidr           = "10.47.0.0/24"
  public_subnet_cidrs = ["10.47.0.0/27", "10.47.0.32/27"]
  private_subnet_cidrs = ["10.47.0.64/27", "10.47.0.96/27"]
  services_subnet_cidrs = ["10.47.0.128/27", "10.47.0.160/27"]
  availability_zones = ["us-west-2a", "us-west-2b"]
}

module "payroll_app" {
  source     = "../modules/payroll-app"
  app_region = lookup(var.region, terraform.workspace)
  ami        = lookup(var.ami, terraform.workspace)
}
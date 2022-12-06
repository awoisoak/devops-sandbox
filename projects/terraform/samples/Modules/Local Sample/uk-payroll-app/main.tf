module "us_payroll" {
  source = "../modules/payroll-ap"
    app_region = "eu-west-2"
    ami = "ami-35s140119877avm"
}
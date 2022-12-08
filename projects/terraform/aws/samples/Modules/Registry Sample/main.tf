module "iam_iam-user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "3.4.0"
  # insert the 1 required variable here
  name = "max"

  # In the module doc https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-user
  # it specifies that by default this module will create user, login profile and access key 
  # We can change the default setup if we only want to create the user: 
  create_iam_access_key         = false
  create_iam_user_login_profile = false
}
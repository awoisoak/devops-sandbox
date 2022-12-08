resource "aws_iam_user" "users" {
  name  = var.project-sapphire-users[count.index]
  count = lentgh(var.project-sapphire-users)

}

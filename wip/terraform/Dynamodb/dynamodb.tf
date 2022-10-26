resource "aws_dynamodb_table" "project_sapphire_user_data" {
  name         = "userdata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"

  attribute {
    name = "UserId"
    type = "N"
  }
}

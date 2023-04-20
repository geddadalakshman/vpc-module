data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {
  id = var.vpc_default_id
}
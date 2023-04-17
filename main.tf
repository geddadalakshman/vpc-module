resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "${var.env}-vpc"
    },
  )

}

#Public subnets

resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "${var.env}-${each.value["name"]}"
    }
  )

  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}

###---public route tables
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    {
      Name = "${var.env}-${each.value["name"]}"
    }
  )
}

#Public route table association
resource "aws_route_table_association" "public_assoc" {

  for_each = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
#                     ---  or ------both syntax are correct
#   subnet_id      = lookup(lookup( aws_subnet.public_subnets, each.value["name"], "null" ), "id" , "null")
  route_table_id = aws_route_table.public_route[each.value["name"]].id
}

#private subnets

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      Name = "${var.env}-${each.value["name"]}"
    }
  )

  for_each = var.private_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

}

###Private route tables
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id

  for_each = var.private_subnets
  tags = merge(
    var.tags,
    {
      Name = "${var.env}-${each.value["name"]}"
    }
  )
}

#Private route table association
resource "aws_route_table_association" "private_assoc" {

  for_each = var.private_subnets
  subnet_id      = aws_subnet.private_subnets[each.value["name"]].id
  route_table_id = aws_route_table.private_route[each.value["name"]].id
}
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = var.gateway_id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "rta" {
  count = length(var.subnet_ids)

  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.route_table.id
}

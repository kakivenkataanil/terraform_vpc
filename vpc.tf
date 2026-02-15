resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    var.vpc_name, var.common_tags,
    {
      Name = "${local.resource_name}-vpc"
    }
  )
}


resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  #   tags = var.common_tags
  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
      Name = local.resource_name
    }
  )
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "main"
    }
  )
}


resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = var.common_tags
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(
    var.common_tags,
    {
      Name = "main"
    }
  )
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    {
      Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}


resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}


resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}


resource "aws_route" "database" {
  route_table_id = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
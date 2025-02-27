resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${var.resource_prefix}_eks_control_plane_sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}_eks_control_plane_sg"
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.resource_prefix}_eks_nodes_sg"
  description = "Security group for EKS nodes"
  vpc_id      = aws_vpc.team_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}_eks_nodes_sg"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.team_vpc.id
  tags = {
    Name = "${var.resource_prefix}_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.resource_prefix}_public_route_table"
  }
}

resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "${var.resource_prefix}_nat_gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.team_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.resource_prefix}_private_route_table"
  }
}

resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

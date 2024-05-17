// VPC //
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "v-task-vpc"
  }
}

// Public Subnet //
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidr
  availability_zone = var.az

  tags = {
    Name = "v-task-public-subnet"
  }
}

// Private Subnet //
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidr
  availability_zone = var.az

  tags = {
    Name = "v-task-private-subnet"
  }
}

// Internet Gateway //
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "v-task-igw"
  }
}

// Elastic IP // 
resource "aws_eip" "eip" {
  domain   = "vpc"
}

// NAT Gateway //
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "v-task-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}


// Public Route Table // 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "v-task-public-rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public_rt.id
}

// Private Route Table //
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "v-task-private-rt"
  }
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_rt.id
}
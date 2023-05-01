resource "aws_vpc" "papa-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "papa-vpc"
  }
}

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.papa-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.papa-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Prod-pub-sub2"
  }
}

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.papa-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.papa-vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Prod-priv-sub2"
  }
}


resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.papa-vpc.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}


resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.papa-vpc.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

resource "aws_route_table_association" "Public-route-l-association" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Public-route-2-association" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}


resource "aws_route_table_association" "Private-route-1-association" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Private-route-2-association" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.papa-vpc.id

  tags = {
    Name = "Prod-igw"
  }
}

# Internet gateway Associate with Public route

resource "aws_route" "Prod-gateway" {
  route_table_id            = aws_route_table.Prod-pub-route-table.id
  gateway_id                = aws_internet_gateway.Prod-igw.id
  destination_cidr_block    = "0.0.0.0/0"
}

# Create Elastic IP Address
resource "aws_eip" "Prod-eip" {
  tags = {
    Name = "Prod-eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "Prod-NAT-gateway" {
  allocation_id = aws_eip.Prod-eip.id
  subnet_id     = aws_subnet.Prod-pub-sub1.id

  tags = {
    Name = "Prod-NAT-gateway"
  }


}

# NAT Associate with Priv route
resource "aws_route" "Prod-Nat-association" {
  route_table_id = aws_route_table.Prod-priv-route-table.id
  gateway_id = aws_nat_gateway.Prod-NAT-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}



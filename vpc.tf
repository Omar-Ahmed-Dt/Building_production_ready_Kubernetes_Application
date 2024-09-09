resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true  
  enable_dns_hostnames = true  

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_subnet" "eks_subnet" {
  count = 3
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)

  map_public_ip_on_launch = true  # Enable auto-assign public IP addresses

  tags = {
    Name = "${local.cluster_name}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = local.cluster_name
  }
}

resource "aws_route_table_association" "eks_route_table_association" {
  count          = 3
  subnet_id      = element(aws_subnet.eks_subnet[*].id, count.index)
  route_table_id = aws_route_table.eks_route_table.id
}

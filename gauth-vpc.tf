data "aws_availability_zones" "available" {
    state = "available"
}

# Create VPC
resource "aws_vpc" "gauth-vpc" {
    cidr_block = "192.168.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"

    tags = {
      Name = "gauth-vpc"
    }
}

# Create Public Subnet
resource "aws_subnet" "gauth-public-subnet-2a" {
    vpc_id = aws_vpc.gauth-vpc.id
    cidr_block = "192.168.0.0/20"
    map_public_ip_on_launch =  true
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        "Name" = "gauth-public-subnet-2a"
    }
}

resource "aws_subnet" "gauth-public-subnet-2b" {
    vpc_id = aws_vpc.gauth-vpc.id
    cidr_block = "192.168.16.0/20"
    map_public_ip_on_launch =  true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        "Name" = "gauth-public-subnet-2b"
    }
}


## Create Private Subnet
resource "aws_subnet" "gauth-private-subnet-2a" {
    vpc_id = aws_vpc.gauth-vpc.id
    cidr_block = "192.168.128.0/20"
    map_public_ip_on_launch =  true
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
        "Name" = "gauth-private-subnet-2a"
    }
}


resource "aws_subnet" "gauth-private-subnet-2b" {
    vpc_id = aws_vpc.gauth-vpc.id
    cidr_block = "192.168.144.0/20"
    map_public_ip_on_launch =  true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        "Name" = "gauth-private-subnet-2b"
    }
}


# Create IGW
resource "aws_internet_gateway" "gauth-igw" {
    vpc_id = aws_vpc.gauth-vpc.id
    tags = {
        Name = "gauth-igw"
    }
}


# Create EIP
resource "aws_eip" "gauth_vpc_nat_ip" {
    vpc = true

    lifecycle {
        create_before_destroy = true
    }
}

# Create Nat
resource "aws_nat_gateway" "gauth-nat" {
    allocation_id = aws_eip.gauth_vpc_nat_ip.id
    subnet_id = aws_subnet.gauth-public-subnet-2a.id

    tags = {
        Name = "gauth-nat"
    }
}



# Create Public RTB
resource "aws_route_table" "gauth-public-rtb" {
    vpc_id = aws_vpc.gauth-vpc.id

    tags = {
        Name = "gauth-public-rtb"
    }
}

## Create Private RTB
resource "aws_route_table" "gauth-private-rtb" {
    vpc_id = aws_vpc.gauth-vpc.id

    tags = {
        Name = "gauth-private-rtb"
    }
}

# Public Subnet Register RTB 
resource "aws_route_table_association" "gauth-public-rt-association-1" {
    subnet_id = aws_subnet.gauth-public-subnet-2a.id
    route_table_id = aws_route_table.gauth-public-rtb.id
}

resource "aws_route_table_association" "gauth-public-rt-association-2" {
    subnet_id = aws_subnet.gauth-public-subnet-2b.id
    route_table_id = aws_route_table.gauth-public-rtb.id
}



## Private Subnet Register RTB
resource "aws_route_table_association" "gauth-private-rt-association-1" {
    subnet_id = aws_subnet.gauth-private-subnet-2a.id
    route_table_id = aws_route_table.gauth-private-rtb.id
}

resource "aws_route_table_association" "gauth-private-rt-association-2" {
    subnet_id = aws_subnet.gauth-private-subnet-2b.id
    route_table_id = aws_route_table.gauth-private-rtb.id
}


# IGW Register RTB
resource "aws_route" "public-rt-igw" {
    route_table_id = aws_route_table.gauth-public-rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gauth-igw.id
}

# Nat Register Rtb
resource "aws_route" "private-rt-nat" {
    route_table_id = aws_route_table.gauth-private-rtb.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gauth-nat.id
}

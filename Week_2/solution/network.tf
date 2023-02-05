// Create a VPC named "prefect_vpc"
resource "aws_vpc" "prefect_vpc" {
  // Here we are setting the CIDR block of the VPC
  // to the "vpc_cidr_block" variable
  cidr_block = var.vpc_cidr_block
  // We want DNS hostnames enabled for this VPC
  enable_dns_hostnames = true

  // We are tagging the VPC with the name "prefect_vpc"
  tags = {
    Name = "prefect_vpc"
  }
}

// Create an internet gateway named "prefect_igw"
// and attach it to the "prefect_vpc" VPC
resource "aws_internet_gateway" "prefect_igw" {
  // Here we are attaching the IGW to the 
  // prefect_vpc VPC
  vpc_id = aws_vpc.prefect_vpc.id

  // We are tagging the IGW with the name prefect_igw
  tags = {
    Name = "prefect_igw"
  }
}

// This data object is going to be
// holding all the available availability
// zones in our defined region
data "aws_availability_zones" "available" {
  state = "available"
}

// Create a group of public subnets based on the variable subnet_count.public
resource "aws_subnet" "prefect_public_subnet" {
  // count is the number of resources we want to create
  // here we are referencing the subnet_count.public variable which
  // current assigned to 1 so only 1 public subnet will be created
  count = var.subnet_count.public

  // Put the subnet into the "prefect_vpc" VPC
  vpc_id = aws_vpc.prefect_vpc.id

  // We are grabbing a CIDR block from the "public_subnet_cidr_blocks" variable
  // since it is a list, we need to grab the element based on count,
  // since count is 1, we will be grabbing the first cidr block 
  // which is going to be 10.0.1.0/24
  cidr_block = var.public_subnet_cidr_blocks[count.index]

  // We are grabbing the availability zone from the data object we created earlier
  // Since this is a list, we are grabbing the name of the element based on count,
  // so since count is 1, and our region is us-east-2, this should grab us-east-2a
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // We are tagging the subnet with a name of "prefect_public_subnet_" and
  // suffixed with the count
  tags = {
    Name = "prefect_public_subnet_${count.index}"
  }
}

// Create a public route table named "prefect_public_rt"
resource "aws_route_table" "prefect_public_rt" {
  // Put the route table in the "prefect_vpc" VPC
  vpc_id = aws_vpc.prefect_vpc.id

  // Since this is the public route table, it will need
  // access to the internet. So we are adding a route with
  // a destination of 0.0.0.0/0 and targeting the Internet 	 
  // Gateway "prefect_igw"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prefect_igw.id
  }
}

// Here we are going to add the public subnets to the 
// "tutorial_public_rt" route table
resource "aws_route_table_association" "public" {
  // count is the number of subnets we want to associate with
  // this route table. We are using the subnet_count.public variable
  // which is currently 1, so we will be adding the 1 public subnet
  count = var.subnet_count.public

  // Here we are making sure that the route table is
  // "prefect_public_rt" from above
  route_table_id = aws_route_table.prefect_public_rt.id

  // This is the subnet ID. Since the "prefect_public_subnet" is a 
  // list of the public subnets, we need to use count to grab the
  // subnet element and then grab the id of that subnet
  subnet_id = aws_subnet.prefect_public_subnet[count.index].id
}

resource "aws_security_group" "prefect_agent" {
  name        = "prefect-agent-sg-${var.name}"
  description = "ECS Prefect Agent"
  vpc_id      = aws_vpc.prefect_vpc.id
}

resource "aws_security_group_rule" "https_outbound" {
  // S3 Gateway interfaces are implemented at the routing level which means we
  // can avoid the metered billing of a VPC endpoint interface by allowing
  // outbound traffic to the public IP ranges, which will be routed through
  // the Gateway interface:
  // https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html
  description       = "HTTPS outbound"
  type              = "egress"
  security_group_id = aws_security_group.prefect_agent.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]

}
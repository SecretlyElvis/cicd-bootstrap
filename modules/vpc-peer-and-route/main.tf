## Create VPC Peering Connection
resource "aws_vpc_peering_connection" "jenkins-to-nexus" {

  vpc_id        = var.jenkins_vpc_id
  peer_vpc_id   = var.nexus_vpc_id

  auto_accept   = true

  tags = merge(
      tomap({
              "Name" = join("-", [ var.name_prefix, "peer" ])
          }),
      var.common_tags
  ) 
}

## Add route for Jenkins -> Nexus traffic in default route table
resource "aws_route" "j-to-n" {
  route_table_id            = var.jenkins_route_table_id 
  destination_cidr_block    = var.nexus_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}

## Add route to Jenkins public subnet route tables
resource "aws_route" "jpubsub-to-n" {

  count = length(var.jenkins_public_rt)

  route_table_id            = var.jenkins_public_rt[count.index]
  destination_cidr_block    = var.nexus_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}

## Add route to Jenkins private subnet route tables
resource "aws_route" "jprisub-to-n" {

  count = length(var.jenkins_private_rt)

  route_table_id            = var.jenkins_private_rt[count.index]
  destination_cidr_block    = var.nexus_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}

## Add route for Nexus -> Jenkins traffic in default route table
resource "aws_route" "n-to-j" {
  route_table_id            = var.nexus_route_table_id 
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}

## Add route to Nexus public subnet route tables
resource "aws_route" "npubsub-to-j" {

  count = length(var.nexus_public_rt)

  route_table_id            = var.nexus_public_rt[count.index]
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}

## Add route to Nexus private subnet route tables
resource "aws_route" "nprisub-to-j" {

  count = length(var.nexus_private_rt)

  route_table_id            = var.nexus_private_rt[count.index]
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.jenkins-to-nexus.id
}
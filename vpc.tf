resource "aws_vpc" "k8s-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "k8s-subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.k8s-vpc.id}"
}

resource "aws_internet_gateway" "k8s-igw" {
  vpc_id = "${aws_vpc.k8s-vpc.id}"

  tags = {
    Name = "k8s-cluster"
  }
}

resource "aws_route_table" "k8s-route-table" {
  vpc_id = "${aws_vpc.k8s-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.k8s-igw.id}"
  }
}

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = "${aws_subnet.k8s-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.k8s-route-table.id}"
}

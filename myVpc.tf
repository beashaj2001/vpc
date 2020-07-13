provider "aws" {
    region ="ap-south-1"
    profile = "beashaj_profile"
}

resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "mynewvpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "mysubnet1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "mysubnet2"
  }
}

resource "aws_security_group" "sg" {
  name        = "sgvpc"
  description = "Security group for VPC"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "mysg"
  }
}

resource "aws_security_group" "mysqlsg" {
  name        = "mysqlsgvpc"
  description = "Security group for MySql"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "SSH"
    from_port   = 3306
    to_port     = 3306
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
    Name = "mysqlmysg"
  }
}

resource "aws_instance" "myin2" {
    ami = "ami-7e257211"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = "${aws_subnet.sub1.id}"
    key_name = "myNewkey2"
    vpc_security_group_ids = [ "${aws_security_group.sg.id}"  ]
    tags = {
        Name = "LinuxWorld2"
    }
}

resource "aws_instance" "mysql_inst" {
    ami = "ami-07a8c73a650069cf3"
    instance_type = "t2.micro"
    associate_public_ip_address = true
    subnet_id = "${aws_subnet.sub2.id}"
    key_name = "myNewkey2"
    vpc_security_group_ids = [ "${aws_security_group.mysqlsg.id}" ]
    tags = {
        Name = "Mysql_LinuxWorld"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "igwmy"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "rtable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.sub1.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

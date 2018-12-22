module "vpc" {
  source       = "../modules/vpc"
  incrementor  = "${var.incrementor}"
  environment  = "${var.environment}"
  agency       = "${var.agency}"
  costcenter   = "${var.costcenter}"
  project      = "${var.project}"
  vpccidrblock = "192.168.0.0/22"
}

resource "aws_subnet" "dev-1" {
  vpc_id     = "${module.vpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "from1"
  }
}

resource "aws_subnet" "dev-2" {
  vpc_id     = "${module.vpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "from2"
  }
}

module "vpc-common" {
  source       = "../modules/vpc"
  incrementor  = "${var.incrementor}"
  environment  = "c"
  agency       = "${var.agency}"
  costcenter   = "${var.costcenter}"
  project      = "${var.project}"
  vpccidrblock = "192.168.4.0/22"
}

resource "aws_subnet" "common-1" {
  vpc_id     = "${module.vpc-common.id}"
  cidr_block = "192.168.4.0/24"
  availability_zone = "${var.az1}"
  tags = {
    Name = "to1"
  }
}

resource "aws_subnet" "common-2" {
  vpc_id     = "${module.vpc-common.id}"
  cidr_block = "192.168.5.0/24"
  availability_zone = "${var.az2}"
  tags = {
    Name = "to2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${module.vpc-common.id}"

  tags = {
    Name = "main"
  }
}

module "ssm" {
  source       = "../modules/ssm"
  environment  = "${var.environment}"
}

module "transit-gateway" {
  source       = "../modules/transit-gateway"
  amazon-asn   = "65411"
  incrementor  = "${var.incrementor}"
  environment  = "${var.environment}"
  agency       = "${var.agency}"
  costcenter   = "${var.costcenter}"
  project      = "${var.project}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tg-vpc-common" {
  subnet_ids         = ["${aws_subnet.common-1.id}",
                        "${aws_subnet.common-2.id}"]
  transit_gateway_id = "${module.transit-gateway.id}"
  vpc_id             = "${module.vpc-common.id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tg-vpc-dev" {
  subnet_ids         = ["${aws_subnet.dev-1.id}",
                        "${aws_subnet.dev-2.id}"]
  transit_gateway_id = "${module.transit-gateway.id}"
  vpc_id             = "${module.vpc.id}"
}

resource "aws_route_table" "dev-rt" {
  vpc_id = "${module.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${module.transit-gateway.id}"
  }
  tags = {
    Name = "dev"
  }
}

resource "aws_route_table" "common-rt" {
  vpc_id = "${module.vpc-common.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = "${module.transit-gateway.id}"
  }

  tags = {
    Name = "common"
  }
}

resource "aws_route_table_association" "dev-rt-assoc-1" {
  subnet_id      = "${aws_subnet.dev-1.id}"
  route_table_id = "${aws_route_table.dev-rt.id}"
}
resource "aws_route_table_association" "dev-rt-assoc-2" {
  subnet_id      = "${aws_subnet.dev-2.id}"
  route_table_id = "${aws_route_table.dev-rt.id}"
}
resource "aws_route_table_association" "common-rt-assoc-1" {
  subnet_id      = "${aws_subnet.common-1.id}"
  route_table_id = "${aws_route_table.common-rt.id}"
}
resource "aws_route_table_association" "common-rt-assoc-2" {
  subnet_id      = "${aws_subnet.common-2.id}"
  route_table_id = "${aws_route_table.common-rt.id}"
}

resource "aws_ec2_transit_gateway_route" "tg-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tg-vpc-common.id}"
  transit_gateway_route_table_id = "${module.transit-gateway.rt-id}"
}

resource "aws_security_group" "dev" {
  name        = "allow_icmp_v4_d"
  description = "Allow ICMP v4"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "common" {
  name        = "allow_icmp_v4_c"
  description = "Allow ICMP v4"
  vpc_id      = "${module.vpc-common.id}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev" {
  ami           = "ami-009d6802948d06e52"
  instance_type = "t2.micro"
  key_name = "ec2-ubuntu-1"
  subnet_id = "${aws_subnet.dev-1.id}"
  associate_public_ip_address = "false"
  vpc_security_group_ids = ["${aws_security_group.dev.id}"]

  tags = {
    Name = "dev"
  }
}

resource "aws_instance" "common" {
  ami           = "ami-009d6802948d06e52"
  instance_type = "t2.micro"
  key_name = "ec2-ubuntu-1"
  subnet_id = "${aws_subnet.common-1.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.common.id}"]

  tags = {
    Name = "common"
  }

  provisioner "remote-exec" {
    inline = [
      "w > /tmp/flee.txt",
      "echo ${aws_instance.dev.private_ip} > /tmp/ip.txt",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      #password    = "${var.root_password}"
      private_key = "${file("../../.ssh/ec2-ubuntu-1.pem")}"
    }
  }
}

variable "agency" {
}

variable "project" {
}

variable "environment" {
}

variable "incrementor" {
}

variable "costcenter" {
}

variable "amazon-asn" {
}

resource "aws_ec2_transit_gateway" "tg" {
  description                     = "tg-${var.agency}-${var.project}-${var.environment}-${var.incrementor}"
  amazon_side_asn                 = "${var.amazon-asn}"
  auto_accept_shared_attachments  = "disable"
  default_route_table_propagation = "enable"
  default_route_table_association = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags {
    Name        = "${var.agency}-${var.project}-${var.environment}-${var.incrementor}-tg"
    environment = "${var.environment}"
    agency      = "${var.agency}"
    project     = "${var.project}"
    costcenter  = "${var.costcenter}"
  }
}

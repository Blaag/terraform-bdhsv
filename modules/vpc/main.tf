resource "aws_vpc" "thisvpc" {
  cidr_block = "${var.vpccidrblock}"
  tags {
    Name = "${var.agency}-${var.project}-${var.environment}-${var.incrementor}-vpc"
    environment = "${var.environment}"
    agency = "${var.agency}"
    project = "${var.project}"
    costcenter = "${var.costcenter}"
  }
}

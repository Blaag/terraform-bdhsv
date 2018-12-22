#
# create vpn gateways
#
resource "aws_customer_gateway" "vgw-lakewood" {
  bgp_asn    = 65001
  ip_address = "165.127.10.10"
  type       = "ipsec.1"

  tags {
    Name = "vgw-lakewood"
  }
}

resource "aws_customer_gateway" "vgw-centennial" {
  bgp_asn    = 65001
  ip_address = "165.127.20.10"
  type       = "ipsec.1"

  tags {
    Name = "vgw-centennial"
  }
}

output "id" {
  value = "${aws_ec2_transit_gateway.tg.id}"
}

output "rt-id" {
  value = "${aws_ec2_transit_gateway.tg.association_default_route_table_id}"
}

output "rp-id" {
  value = "${aws_ec2_transit_gateway.tg.propagation_default_route_table_id}"
}

output "owner_id" {
  value = "${aws_ec2_transit_gateway.tg.owner_id}"
}

output "arn" {
  value = "${aws_ec2_transit_gateway.tg.arn}"
}

output "arn" {
  value = "${aws_vpc.thisvpc.arn}"
}

output "id" {
  value = "${aws_vpc.thisvpc.id}"
}

output "cidr_block" {
  value = "${aws_vpc.thisvpc.cidr_block}"
}

output "instance_tenancy" {
  value = "${aws_vpc.thisvpc.instance_tenancy}"
}

output "enable_dns_support" {
  value = "${aws_vpc.thisvpc.enable_dns_support}"
}

output "enable_dns_hostnames" {
  value = "${aws_vpc.thisvpc.enable_dns_hostnames}"
}

output "main_route_table_id" {
  value = "${aws_vpc.thisvpc.main_route_table_id}"
}

output "default_network_acl_id" {
  value = "${aws_vpc.thisvpc.default_network_acl_id}"
}

output "default_route_table_id" {
  value = "${aws_vpc.thisvpc.default_route_table_id}"
}

#output "owner_id" {
  #value = "${aws_vpc.thisvpc.owner_id}"
#}

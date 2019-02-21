provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

provider "aws" {
  alias = "secondary"
  access_key = "${var.aws_access_key_secondary}"
  secret_key = "${var.aws_secret_key_secondary}"
  region     = "us-west-2"
}

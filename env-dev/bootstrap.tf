variable "infrastructure_version" {
  default = "1"
}

terraform {
  backend "s3" {
    encrypt = true
    bucket  = "terraform-clapthreetimes"
    region  = "us-east-1"
    key     = "v1"
  }
}

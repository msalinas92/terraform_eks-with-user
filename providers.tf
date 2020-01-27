provider "aws" {
  profile    = "default"
  region     = "${var.region}"
  access_key = "${var.access-key}"
  secret_key = "${var.secret-key}"
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}


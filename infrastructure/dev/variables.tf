variable "aws_region" {}

variable "apex_function_lambda_auto_scaling_spot_fleet_based_on_cpu_usage" {}

variable "name" {
  default = "lambda_auto_scaling_spot_fleet_based_on_cpu_usage"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_types" {
  default = {
    m3_medium = "m3.medium"
    m3_large  = "m3.large"
  }
}

variable "spot_prices" {
  default = {
    max       = "0.1"
    m3_medium = "0.07"
    m3_large  = "0.08"
  }
}

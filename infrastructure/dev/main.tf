module "iam" {
  source = "../modules/iam"
}

module "spot_fleet" {
  source = "../modules/spot_fleet"

  name           = "${var.name}"
  vpc_cidr       = "${var.vpc_cidr}"
  instance_types = "${var.instance_types}"
  spot_prices    = "${var.spot_prices}"
}

module "cloudwatch_events" {
  source = "../modules/cloudwatch_events"

  name       = "${var.name}"
  lambda_arn = "${var.apex_function_lambda_auto_scaling_spot_fleet_based_on_cpu_usage}"
}

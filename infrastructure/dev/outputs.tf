output "lambda_function_role_id" {
  value = "${module.iam.lambda_function_role_id}"
}

output "spot_fleet_id" {
  value = "${module.spot_fleet.spot_fleet_id}"
}

output "spot_fleet_request_state" {
  value = "${module.spot_fleet.spot_fleet_request_state}"
}

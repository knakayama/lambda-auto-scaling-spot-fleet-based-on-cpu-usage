resource "aws_iam_role" "lambda_function" {
  name               = "lambda-auto-scaling-spot-fleet-based-on-cpu-usage-role"
  assume_role_policy = "${file("${path.module}/policies/lambda_assume_role_policy.json")}"
}

resource "aws_iam_policy_attachment" "cloudwatch_full_access" {
  name       = "CloudWatchFullAccess"
  roles      = ["${aws_iam_role.lambda_function.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy" "lambda_function" {
  name   = "ModifySpotFleetRequest"
  role   = "${aws_iam_role.lambda_function.id}"
  policy = "${file("${path.module}/policies/modify_spot_fleet_request_policy.json")}"
}

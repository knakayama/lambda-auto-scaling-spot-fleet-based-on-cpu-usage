resource "aws_iam_role" "spot_fleet_role" {
  name               = "spot-fleet-role"
  assume_role_policy = "${file("${path.module}/policies/assume_role_policy.json")}"
}

resource "aws_iam_policy_attachment" "fleet_role" {
  name       = "EC2SpotFleetRole"
  roles      = ["${aws_iam_role.spot_fleet_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}

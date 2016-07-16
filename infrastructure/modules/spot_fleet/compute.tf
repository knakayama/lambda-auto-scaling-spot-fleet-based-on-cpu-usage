resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("${path.module}/keys/site_key.pub")}"
}

resource "aws_spot_fleet_request" "fleet" {
  iam_fleet_role = "${aws_iam_role.spot_fleet_role.arn}"
  spot_price     = "${var.spot_prices["max"]}"

  #allocation_strategy                 = "lowestPrice"
  allocation_strategy                 = "diversified"
  terminate_instances_with_expiration = true
  excess_capacity_termination_policy  = "Default"
  target_capacity                     = 6
  valid_until                         = "2017-07-14T06:22:35Z"

  launch_specification {
    instance_type               = "${var.instance_types["m3_medium"]}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    key_name                    = "${aws_key_pair.site_key.key_name}"
    spot_price                  = "${var.spot_prices["m3_medium"]}"
    availability_zone           = "${data.aws_availability_zones.azs.names[0]}"
    subnet_id                   = "${aws_subnet.public.0.id}"
    vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
    weighted_capacity           = 1
    associate_public_ip_address = true

    root_block_device {
      volume_size = "8"
      volume_type = "gp2"
    }
  }

  launch_specification {
    instance_type               = "${var.instance_types["m3_large"]}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    key_name                    = "${aws_key_pair.site_key.key_name}"
    spot_price                  = "${var.spot_prices["m3_large"]}"
    availability_zone           = "${data.aws_availability_zones.azs.names[1]}"
    subnet_id                   = "${aws_subnet.public.1.id}"
    vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
    weighted_capacity           = 2
    associate_public_ip_address = true

    root_block_device {
      volume_size = "8"
      volume_type = "gp2"
    }
  }
}

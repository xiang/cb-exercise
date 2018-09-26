resource "aws_autoscaling_policy" "api" {
  name                   = "api"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = "${aws_autoscaling_group.api.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}

resource "aws_autoscaling_group" "api" {
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  min_size = 1
  max_size = 2
  launch_template = {
    id = "${aws_launch_template.api.id}"
    version = "$$Latest"
  }
  health_check_grace_period = 60
}

resource "aws_launch_template" "api" {
  name = "api"

  image_id = "${data.aws_ami.ubuntu.id}"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = "api"

  monitoring {
    enabled = true
  }

  #network_interfaces {
  #  associate_public_ip_address = true
  #  subnet_id = "subnet-2aa88f42"
  #  security_groups = ["${aws_security_group.allow_all.id}"]
  #}
  security_group_names = ["allow_all"]

  tag_specifications {
    resource_type = "instance"
    tags {
      Name = "api"
    }
  }

  user_data = "${data.template_cloudinit_config.api.rendered}"
}

data "template_cloudinit_config" "api" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${file("bootstrap.sh")}"
  }
}

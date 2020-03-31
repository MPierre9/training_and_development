resource "aws_launch_configuration" "example-launchconfig" {
  name_prefix     = "example-launchconfig"
  image_id        = var.amis[var.region]
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.terraform_learning_key_pair.key_name
  security_groups = [aws_security_group.terraform_learn_security_group.id]

}

resource "aws_autoscaling_group" "example-autoscaling" {
  name                      = "example-autoscaling"
  vpc_zone_identifier       = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  launch_configuration      = aws_launch_configuration.example-launchconfig.name
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.test.arn]

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }

}
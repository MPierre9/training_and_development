# AWS Load Balancer

resource "aws_lb" "tf-test-elb" {
  name               = "tf-test-elb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups    = [aws_security_group.terraform_learn_elb_security_group.id]


  enable_cross_zone_load_balancing = true
  tags = {
    Name = "tf-test-elb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.tf-test-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.example.id
  port             = 80
}

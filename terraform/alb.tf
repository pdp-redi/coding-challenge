# application load balancer
resource "aws_lb" "alb" {
  name               = "${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for i in aws_subnet.public_subnets : i.id] #aws_subnet.public_subnets[*].id 
}

# target group for alb
resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.env}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    matcher             = "200"
  }
}

# #listener for alb
# resource "aws_lb_listener" "alb_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_tg.id
#   }
#   tags = {
#     Name = "${var.env}-alb-listenter"
#   }
# }

# HTTP listener for alb
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "${var.env}-alb-listenter"
  }
  depends_on = [aws_lb_target_group.alb_tg]
}

# HTTPS listener for alb
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm.arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
  depends_on = [aws_lb_target_group.alb_tg]
}

# alb listener certificate
resource "aws_lb_listener_certificate" "https_additional_certs" {
  #count           = length(var.additional_certs)  
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.acm.arn
}



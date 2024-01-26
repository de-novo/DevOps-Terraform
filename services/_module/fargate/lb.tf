############################################
# 해당 관련 내용 root/lb/alb 로 이동            
############################################


# ############ Security Group For External LB
# resource "aws_security_group" "external_lb" {
#   name        = "${var.service_name}-${var.vpc_name}-ext"
#   description = "${var.service_name} external LB SG"
#   vpc_id      = var.target_vpc

#   # Only allow access from IPs or SGs you specifiy in ext_lb_ingress_cidrs variables
#   # If you don't want to use HTTPS then remove this block
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = var.ext_lb_ingress_cidrs
#     description = "External service https port"
#   }


#   # Allow 80 port 
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = var.ext_lb_ingress_cidrs
#     description = "External service http port"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.0.0.0/8"]
#     description = "Internal outbound any traffic"
#   }

#   tags = var.sg_variables.external_lb.tags[var.shard_id]
# }




# #################### External ALB
# resource "aws_lb" "external" {
#   name     = "${var.service_name}-${var.shard_id}-ext"
#   subnets  = var.public_subnets
#   internal = false

#   # For external LB,
#   # Home SG (Includes Office IPs) could be added if this service is internal service.
#   security_groups = [
#     aws_security_group.external_lb.id,
#     var.home_sg,
#   ]

#   # For HTTP service, application LB is recommended.
#   # You could use other load_balancer_type if you want.
#   load_balancer_type = "application"

#   tags = var.lb_variables.external_lb.tags[var.shard_id]
# }

# #################### External LB Target Group 
# resource "aws_lb_target_group" "external" {
#   name                 = "${var.service_name}-${var.shard_id}-ext"
#   port                 = 80
#   target_type          = "instance"
#   protocol             = "HTTP"
#   vpc_id               = var.target_vpc
#   slow_start           = var.lb_variables.target_group_slow_start[var.shard_id]
#   deregistration_delay = var.lb_variables.target_group_deregistration_delay[var.shard_id]
#   # Change the health check setting 


#   tags = var.lb_variables.external_lb_tg.tags[var.shard_id]

#   health_check {
#     path                = var.healthcheck_path
#     healthy_threshold   = 2
#     unhealthy_threshold = 10
#     timeout             = 60
#     interval            = 300
#     matcher             = "200-399"
#   }

# }

# #################### Listener for HTTPS service
# resource "aws_lb_listener" "external_443" {
#   load_balancer_arn = aws_lb.external.arn
#   port              = "443"
#   protocol          = "HTTPS"


#   # If you want to use HTTPS, then you need to add certificate_arn here.
#   certificate_arn = var.acm_external_ssl_certificate_arn

#   default_action {
#     target_group_arn = aws_lb_target_group.external.arn
#     type             = "forward"
#   }
# }

# #################### Listener for HTTP service
# resource "aws_lb_listener" "external_80" {
#   load_balancer_arn = aws_lb.external.arn
#   port              = "80"
#   protocol          = "HTTP"

#   # This is for redirect 80. 
#   # This means that it will only allow HTTPS(443) traffic
#   default_action {
#     type = "redirect"

#     redirect {
#       port     = "443"
#       protocol = "HTTPS"
#       # 301 -> Permanant Movement
#       status_code = "HTTP_301"
#     }
#   }
# }



# resource "aws_lb_listener_rule" "external" {
#   listener_arn = aws_lb_listener.external_443.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.external.arn
#   }
#   condition {
#     path_pattern {

#       values = ["*"]
#     }
#   }
# }
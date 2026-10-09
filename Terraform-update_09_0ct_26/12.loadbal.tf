


# resource "aws_lb" "traefik" {

#   name               = "basik-traefik-nlb-v135"
#   internal           = false
#   load_balancer_type = "network"

#   subnets = var.private_subnet_ids

#   enable_cross_zone_load_balancing = true

#   tags = {
#     Name = "basik-traefik-nlb"
#   }
# }

# resource "aws_lb_target_group" "traefik_http" {

#   name        = "traefik-http"
#   port        = 80
#   protocol    = "TCP"

#   target_type = "instance"

#   vpc_id = var.vpc_id

#   health_check {

#     protocol = "TCP"
#     port     = "traffic-port"
#   }
# }

# resource "aws_lb_listener" "http" {

#   load_balancer_arn = aws_lb.traefik.arn

#   port     = 80
#   protocol = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.traefik_http.arn
#   }
# }

# resource "aws_lb_listener" "https" {

#   load_balancer_arn = aws_lb.traefik.arn

#   port     = 443
#   protocol = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.traefik_http.arn
#   }
# }

# #################################################################
# resource "aws_lb_target_group_attachment" "worker_nodes" {

#   for_each = {
#     for idx, instance in data.aws_instances.eks.ids :
#     idx => instance
#   }

#   target_group_arn = aws_lb_target_group.traefik_http.arn

#   target_id = each.value
#   port      = 30080
# }
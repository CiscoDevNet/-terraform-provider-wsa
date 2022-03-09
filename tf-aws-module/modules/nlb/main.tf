################################################################################
# Network Load Balancer
################################################################################
resource "aws_lb" "external_lb" {
  count              = var.create_lb ? 1 : 0
  name               = var.name
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = range(length(var.subnets))
    content {
      subnet_id = var.subnets[subnet_mapping.key]
      allocation_id = (
        var.create_load_balancer_eip ? var.eip[subnet_mapping.key] : null
      )
    }
  }
}

# Creates the target-group
resource "aws_lb_target_group" "main" {
  count = var.create_lb ? length(var.listeners) : 0

  vpc_id = var.vpc_id

  name = tostring(
    "main-${var.name}-${lookup(var.listeners[count.index], "port")}"
  )

  port        = lookup(var.listeners[count.index], "port")
  protocol    = lookup(var.listeners[count.index], "protocol")
  target_type = "instance"

  health_check {
    interval = 30
    protocol = var.health_check.protocol
    port     = var.health_check.port
  }
}

# create listeners
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.external_lb[0].arn

  count = var.create_lb ? length(var.listeners) : 0

  port     = lookup(var.listeners[count.index], "port")
  protocol = lookup(var.listeners[count.index], "protocol")

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[count.index].arn
  }
}

# Register instances with the target group
resource "aws_lb_target_group_attachment" "tgr_attachment" {
  # create indexes based on listener port and
  # number of instances
  for_each = {
    for pair in setproduct(
      range(length(var.listeners)), range(length(var.instances))
    )
    : "${pair[0]} ${pair[1]}" => {
      arn_index = pair[0]
      id_index  = pair[1]
    } if var.create_lb
  }

  target_group_arn = aws_lb_target_group.main[each.value.arn_index].arn
  target_id        = var.instances[each.value.id_index]
}

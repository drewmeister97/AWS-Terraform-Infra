resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc" # Use this instead of `vpc = true`

  tags = {
    Name = "${var.name}-nat-eip"
  }
}


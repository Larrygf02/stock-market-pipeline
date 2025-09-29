
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "generated-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"

  ingress {
    description = "Allow SSH from anywhere (solo para pruebas)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Grafana from anywhere (solo para pruebas)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_stock_market" {
  ami                         = "ami-0953476d60561c955" # Amazon Linux 2
  instance_type               = "t3.small"
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "EC2 Stock Market"
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.generated_key.private_key_pem
  filename        = "${path.module}/generated-key.pem"
  file_permission = "0400"
}

output "ssh_command" {
  value = "ssh -i generated-key.pem ec2-user@ec2-${replace(aws_instance.ec2_stock_market.public_ip, ".", "-")}.compute-1.amazonaws.com"
}

resource "local_file" "ansible_inventory" {
  content  = <<-EOT
  [ec2]
  ec2_stock_market ansible_host=ec2-${replace(aws_instance.ec2_stock_market.public_ip, ".", "-")}.compute-1.amazonaws.com ansible_user=ec2-user ansible_ssh_private_key_file=../terraform/generated-key.pem
  EOT
  filename = "${path.module}/../ansible/inventory.ini"
}

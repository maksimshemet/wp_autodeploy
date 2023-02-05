variable "key_name" {}

resource "tls_private_key" "wp_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wp_pub_key" {
  key_name   = var.key_name
  public_key = tls_private_key.wp_priv_key.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name = aws_key_pair.wp_pub_key.key_name
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  user_data = file("startup.sh")
  
  tags = {
    Name = "web-server"
  }
}

resource "aws_security_group" "web-sg" {
  name        = "web-security-group"
  description = "Allow HTTP and SSH access"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "private_key" {
  value     = tls_private_key.wp_priv_key.private_key_pem
  sensitive = true
}

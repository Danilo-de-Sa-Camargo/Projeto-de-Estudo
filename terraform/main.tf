terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# security group: libera so a porta da aplicacao e ssh
resource "aws_security_group" "api_sg" {
  name        = "api-simples-sg"
  description = "permite trafego da aplicacao e ssh"

  ingress {
    description = "porta da aplicacao"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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

# role que a instancia ec2 vai assumir (sem credencial fixa)
resource "aws_iam_role" "ec2_role" {
  name = "api-simples-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# exemplo de policy de menor privilegio: so permite ler de um bucket especifico
resource "aws_iam_role_policy" "least_privilege_policy" {
  name = "leitura-bucket-especifico"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::meu-bucket-artefatos/*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "api-simples-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# instancia ec2 (free tier) que vai rodar o container da aplicacao
resource "aws_instance" "api_server" {
  ami                  = "ami-0c7217cdde317cfec" # ubuntu 22.04 - us-east-1, confirme antes de aplicar
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.api_sg.name]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "api-simples-server"
  }
}

output "instance_public_ip" {
  value = aws_instance.api_server.public_ip
}

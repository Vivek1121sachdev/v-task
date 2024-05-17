// Public EC2 AMI //
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

// Security Group of Public EC2 Instance //
resource "aws_security_group" "public-instance_sg" {
  name        = "Public-InstanceSecurityGroup"
  description = "Security group for Public EC2 instance"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "v_task_public_ec2_sg"
  }
}

// Security Group of Private EC2 Instance //
resource "aws_security_group" "private-instance_sg" {
  name        = "Private-InstanceSecurityGroup"
  description = "Security group for Private EC2 instance"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.lambda_sg]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public-instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "v_task_private_ec2_sg"
  }
}


// KeyPair For Public Instance //
resource "aws_key_pair" "public-key-pair" {
  key_name = "public-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "public-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "public-tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.root}/objects/public-key-pair.pem"
}


// KeyPair For Private Instance //
resource "aws_key_pair" "key-pair" {
  key_name = "key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.root}/objects/key-pair.pem"
}


// Public EC2 Instance //
resource "aws_instance" "public-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "public-key-pair"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  subnet_id  = var.public_subnet
  security_groups = [aws_security_group.public-instance_sg.id]
  associate_public_ip_address = true
  user_data = file("${path.root}/objects/public_ec2.sh")

  tags = {
    Name = "v-task-public-ec2"
  }
}

// Private EC2 Instance //
resource "aws_instance" "private-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "key-pair"
  subnet_id  = var.private_subnet
  security_groups = [aws_security_group.private-instance_sg.id]
  associate_public_ip_address = false
  user_data = file("${path.root}/objects/private_ec2.sh")

  tags = {
    Name = "v-task-private-ec2"
  }
}
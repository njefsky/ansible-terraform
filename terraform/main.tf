variable "aws_region" {}

variable "profile" {}
variable "server_port" {}

variable "key_name" {}
variable "public_key" {}
variable "private_key" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {} 
variable "aws_availability_zone" {}


# instance
variable "aws_ami_id" {}


provider "aws" {
  profile    = var.profile
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}


resource "aws_security_group" "devotest" {
  name = "terraform-example-instance"  
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ebs_volume" "awx" {
  availability_zone = aws_instance.devotest.availability_zone
  size              = 50

  tags = {
    Name = "tmp"
  }
}


resource "aws_instance" "devotest" {
  ami = var.aws_ami_id
  instance_type = "t2.micro"
  key_name = var.key_name
  #vpc_security_group_ids = ["sg-0d9ecfc76cc0661c9"]
  vpc_security_group_ids = [aws_security_group.devotest.id]
  tags = {
    Name = "terraform-devotest"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
              yum install -y httpd mariadb-server
              systemctl start httpd
              systemctl enable httpd
              systemctl start mariadb
              systemctl enable mariadb
              usermod -a -G apache apache
              chown -R apache:apache /var/www
              chmod 2775 /var/www
              find /var/www -type d -exec chmod 2775 {} \;
              find /var/www -type f -exec chmod 0664 {} \;
              echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
   EOF

}

resource "aws_volume_attachment" "tmp_attachement" {
  device_name  = "/dev/xvdb"
  instance_id  = aws_instance.devotest.id
  volume_id    = aws_ebs_volume.awx.id
  # skip_destroy = "true"
}


output "public_ip" {
  value       = aws_instance.devotest.public_ip
  description = "The public IP of the web server"
}

output "name" {
  value       = aws_instance.devotest.tags.Name
  description = "The Name of the web server"
}

output "state" {
  value       = aws_instance.devotest.instance_state
  description = "The state of the web server"
}


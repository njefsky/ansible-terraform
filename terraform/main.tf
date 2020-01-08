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

resource "aws_ebs_volume" "tmp" {
  availability_zone = aws_instance.devotest_web.availability_zone
  size              = 10
  tags = {
    Name = "tmp"
  }
}


resource "aws_instance" "devotest_web" {
  ami = var.aws_ami_id
  instance_type = "t2.micro"
  key_name = var.key_name
  #vpc_security_group_ids = ["sg-0d9ecfc76cc0661c9"]
  vpc_security_group_ids = [aws_security_group.devotest.id]
  tags = {
    Name = "terraform-devotest"
  }
  root_block_device {
    delete_on_termination = true
  }

  # user_data = <<-EOF
  #             #!/bin/bash
  #             yum update -y
  #             amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
  #             yum install -y httpd
  #             systemctl start httpd
  #             systemctl enable httpd
  #             usermod -a -G apache apache
  #             chown -R apache:apache /var/www
  #             chmod 2775 /var/www
  #             find /var/www -type d -exec chmod 2775 {} \;
  #             find /var/www -type f -exec chmod 0664 {} \;
  #  EOF

}

resource "aws_instance" "devotest_db" {
  ami = var.aws_ami_id
  instance_type = "t2.micro"
  key_name = var.key_name
  #vpc_security_group_ids = ["sg-0d9ecfc76cc0661c9"]
  vpc_security_group_ids = [aws_security_group.devotest.id]
  tags = {
    Name = "terraform-devotest"
  }
  root_block_device {
    delete_on_termination = true
  }

  # user_data = <<-EOF
  #             #!/bin/bash
  #             yum update -y
  #             amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
  #             yum install -y mariadb-server
  #             systemctl start mariadb
  #             systemctl enable mariadb
  # EOF

}

resource "aws_volume_attachment" "tmp_attachement" {
  device_name  = "/dev/xvdb"
  instance_id  = aws_instance.devotest_web.id
  volume_id    = aws_ebs_volume.tmp.id
  # skip_destroy = "true"
}


output "public_ip_web" {
  value       = aws_instance.devotest_web.public_ip
  description = "The public IP of the web server"
}

output "name_web" {
  value       = aws_instance.devotest_web.tags.Name
  description = "The Name of the web server"
}

output "state_web" {
  value       = aws_instance.devotest_web.instance_state
  description = "The state of the web server"
}


output "public_ip_db" {
  value       = aws_instance.devotest_db.public_ip
  description = "The public IP of the db server"
}

output "name_db" {
  value       = aws_instance.devotest_db.tags.Name
  description = "The Name of the db server"
}

output "state_db" {
  value       = aws_instance.devotest_db.instance_state
  description = "The state of the db server"
}


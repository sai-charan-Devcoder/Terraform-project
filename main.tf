
provider "aws" {
  region  = "us-east-1"
  access_key="AKIAVHOIQYDCROMXFWOR"
secret_key="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"
}



resource "aws_vpc" "cloudknowledgevpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "cloudknowledgevpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.cloudknowledgevpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.cloudknowledgevpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_security_group" "cloudknowledgesg" {
  name        = "cloudknowledgesg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cloudknowledgevpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "cloudknowledge-sg"
  }
}

resource "aws_internet_gateway" "cloudknowledge-igw" {
  vpc_id = aws_vpc.cloudknowledgevpc.id

  tags = {
    Name = "cloudknowledge-igw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.cloudknowledgevpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudknowledge-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public-assoc" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_key_pair" "cloudknowledgekey" {
  key_name   = "cloudknowledgekey"
  public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMm/aIfCrnaimVJL6rV35drkesD8eABZF3WgBXR6WoKfV2nkDnhRUJfF6LDi/KLcG53mju9lGfvvoTz9qMgbVx2sTEjFmXBbR45sLzZyG4s9bmwAFqBcQuQ8uprPgg9k7THFzoCAQK2W139va2Qhbrr4Pf9qN14fnklIeW7vdyPcRV7GRvzkOYhg2PuypW50VC3bOISRfLUPereedY+fMDA5/q05Wh0Zu5YyET/fmWgk2wOQ9mfd7b50o5gojX4zQURfClW8PacXP+N5cgh2KqQU5wwNVKa2QZtBT6djoEXx+NVld8BM0i02Ujx+GnllRR1RH/MYXaCTX/LoHOSJ6r cloudshell-user@ip-10-1-36-223.ec2.internal"

}

resource "aws_instance" "cloudknowledgeinstance" {
  ami =  "ami-08e4e35cccc6189f4"
  instance_type = "t2.micro"
 subnet_id= aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.cloudknowledgesg.id]
  key_name="cloudknowledgekey"


  tags = {
    Name = "Cloudknowledge"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_eip" "cloudknowledge-ip" {
  instance = aws_instance.cloudknowledgeinstance.id
  vpc      = true
}

resource "aws_instance" "db-instance" {
  ami =  "ami-08e4e35cccc6189f4"
  instance_type = "t2.micro"
 subnet_id= aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.cloudknowledgesg.id]
  key_name="cloudknowledgekey"


  tags = {
    Name = "db-instance"
  }
}
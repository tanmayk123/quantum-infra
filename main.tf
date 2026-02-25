# This creates the main VPC
resource "aws_vpc" "quantum-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "quantum-vpc-dev"
  }
}

resource "aws_subnet" "quantum-public-subnet" {
  vpc_id                  = aws_vpc.quantum-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_AZ
  tags = {
    Name = "quantum-public-subnet"
  }
}

resource "aws_internet_gateway" "quantum-igw" {
  vpc_id = aws_vpc.quantum-vpc.id
  tags = {
    Name = "quantum-igw"
  }
}

# This creates the aws route table
resource "aws_route_table" "quantum_route_public_table" {
  vpc_id = aws_vpc.quantum-vpc.id
}

resource "aws_route" "quantum_route_public" {
  route_table_id         = aws_route_table.quantum_route_public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.quantum-igw.id
}

resource "aws_route_table_association" "quantum_rt_assoc" {
  route_table_id = aws_route_table.quantum_route_public_table.id
  subnet_id      = aws_subnet.quantum-public-subnet.id
}

# This creates the aws security groups
resource "aws_security_group" "quantus_sg" {
  vpc_id = aws_vpc.quantum-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "quantum-web-ec2" {

  ami             = "ami-09c20105c9b62f893"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.quantum-public-subnet.id
  security_groups = [aws_security_group.quantus_sg.id]

  user_data = <<-EOF
                #!/bin/bash              
                
                dnf install java-17-amazon-corretto -y
                
                export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64
                
                cd /opt
                wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
                tar -xvzf apache-tomcat-9.0.85.tar.gz
                chmod +x apache-tomcat-9.0.85/bin/*.sh
                sh apache-tomcat-9.0.85/bin/startup.sh
                EOF
  tags = {
    Name = "Tomcat-Server"
  }

}

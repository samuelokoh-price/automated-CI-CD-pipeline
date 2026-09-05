# =================================================================
# 1. NETWORKING SETUP
# =================================================================

resource "aws_vpc" "web_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = { Name = "web-vpc" }
}

resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id
  
  tags = { Name = "web-igw" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = { Name = "public-subnet" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
  
  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# =================================================================
# 2. SECURITY GROUP (FIREWALL WITH HTTP & SSH OPENED)
# =================================================================

resource "aws_security_group" "web_sg" {
  name        = "webapp-security-group"
  description = "Allow inbound HTTP web traffic and SSH management access"
  vpc_id      = aws_vpc.web_vpc.id

  # Inbound HTTP Web Traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound SSH Terminal Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic (Allows server to download packages/updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# =================================================================
# 3. UBUNTU IMAGE DYNAMIC DETECTOR
# =================================================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =================================================================
# 4. EC2 COMPUTE INSTANCE WITH USER DATA & KEY PAIR
# =================================================================

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id 
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  key_name               = "dev-prctcs"

  user_data = <<-EOF
              #!/bin/bash
              # Wait for cloud-init background upgrades to yield apt-lock
              while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done
              
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Deployed via Terraform!</h1>" | sudo tee /var/www/html/index.html
              EOF

  tags = {
    Name = "MyWebAppInstance"
  }
}

# =================================================================
# 5. OUTPUTS
# =================================================================

output "webapp_public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "The public IP address of the web application server."
}

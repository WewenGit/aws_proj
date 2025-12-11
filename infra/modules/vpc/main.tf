resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.name }
}

# Subnets publics
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = { Name = "${var.name}-public-${count.index + 1}" }
}

# Subnets privés
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  tags = { Name = "${var.name}-private-${count.index + 1}" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-igw" }
}

# Route Table public
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name}-public-rt" }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# EC2 Instance
resource "aws_instance" "ec2" {
  count                     = 1
  ami                       = var.ec2_ami
  instance_type             = var.ec2_type
  subnet_id                 = aws_subnet.public[0].id
  associate_public_ip_address = true
  security_groups           = [aws_security_group.ec2_sg.id]
  tags = { Name = "${var.name}-ec2" }
}

# RDS Instance
resource "aws_db_instance" "rds" {
  identifier              = "${var.name}-rds"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "admin"
  password                = "projcloud123"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = false #impossible avec un compte etudiant
  publicly_accessible     = false
  skip_final_snapshot     = true

  tags = { Name = "${var.name}-rds" }
}

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = { Name = "${var.name}-rds-subnet-group" }
}

# Security Group pour EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id      = aws_vpc.this.id
  name        = "${var.name}-sg"
  description = "Allow SSH and 8080"
  
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

  tags = { Name = "${var.name}-sg" }
}

# pour RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Allow MySQL access only from EC2"
  vpc_id      = aws_vpc.this.id

  # Access for EC2
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  # EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-rds-sg" }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.name}-web-sg"
  description = "Minimal SG for EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["193.52.208.97/32"]
  }

  # SSH optionnel
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["193.52.208.97/32"]
  }

  # Egress ouvert pour la sortie internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-web-sg" }
}
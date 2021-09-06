 
resource "aws_vpc" "vpc" {
        cidr_block              = var.vpc_cidr
        instance_tenancy        = "default"
        enable_dns_hostnames    = true

         
}

 
resource "aws_internet_gateway" "igw" {
        vpc_id                  = aws_vpc.vpc.id
         

}

 

resource "aws_subnet" "publicsubnet2" {
        vpc_id                  = aws_vpc.vpc.id
        cidr_block              = var.publicsubnet2.cidr
        availability_zone       = var.publicsubnet2.az
        map_public_ip_on_launch = true

        
}
 

resource "aws_subnet" "publicsubnet1" {
        vpc_id                  = aws_vpc.vpc.id
        cidr_block              = var.publicsubnet1.cidr
        availability_zone       = var.publicsubnet1.az
        map_public_ip_on_launch = true

         
}

 

resource "aws_subnet" "privatesubnet1" {
        vpc_id                  = aws_vpc.vpc.id
        cidr_block              = var.privatesubnet1.cidr
        availability_zone       = var.privatesubnet1.az
        map_public_ip_on_launch = false

         
}

 

resource "aws_subnet" "privatesubnet2" {
        vpc_id                  = aws_vpc.vpc.id
        cidr_block              = var.privatesubnet2.cidr
        availability_zone       = var.privatesubnet2.az
        map_public_ip_on_launch = false

         
}

 

resource "aws_eip" "nat" {
        vpc                     = true
         
}

 

resource "aws_nat_gateway" "nat" {
        allocation_id           = aws_eip.nat.id
        subnet_id               = aws_subnet.publicsubnet1.id

        
}

 

resource "aws_route_table" "public" {
        vpc_id                  = aws_vpc.vpc.id

        route {
                cidr_block      = "0.0.0.0/0"
                gateway_id      = aws_internet_gateway.igw.id
        }

         
}

 

resource "aws_route_table" "private" {
        vpc_id                  = aws_vpc.vpc.id
        route {
                cidr_block      = "0.0.0.0/0"
                nat_gateway_id  = aws_nat_gateway.nat.id
        }

         
}

 

resource "aws_route_table_association" "publicsubnet1" {
        subnet_id               = aws_subnet.publicsubnet1.id
        route_table_id          = aws_route_table.public.id
}

resource "aws_route_table_association" "publicsubnet2" {
        subnet_id               = aws_subnet.publicsubnet2.id
        route_table_id          = aws_route_table.public.id
}

 

resource "aws_route_table_association" "privatesubnet1" {
        subnet_id               = aws_subnet.privatesubnet1.id
        route_table_id          = aws_route_table.private.id
}

resource "aws_route_table_association" "privatesubnet2" {
        subnet_id               = aws_subnet.privatesubnet2.id
        route_table_id          = aws_route_table.private.id
}

 

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}


resource "aws_security_group" "bastion" {
        name                    = "bastion"
        vpc_id                  = aws_vpc.vpc.id

        ingress {
                from_port        = 22
                to_port          = 22
                protocol         = "tcp"
                cidr_blocks      = [ "${chomp(data.http.myip.body)}/32"]
        }

        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

}

resource "aws_security_group" "private_sg" {
        name                    = "webserver"
        vpc_id                  = aws_vpc.vpc.id
  
        ingress {
    
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                security_groups  = [ aws_security_group.bastion.id ]
        }
  
        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

        tags = {
                Name = "webserver"
        }
}

resource "aws_security_group" "public_sg" {
    
        name        = "database"

        vpc_id      = aws_vpc.vpc.id

        ingress {
    
                from_port        = 80
                to_port          = 80
                protocol         = "tcp"
                cidr_blocks      = [ "${chomp(data.http.myip.body)}/32" ]

        }
  
        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

         
}


 

resource "aws_key_pair" "key" {

  key_name   = "kp"
  public_key = file("pkey.pub")
 
    
}

# 


resource  "aws_instance"  "app" {
    
        ami                           =     var.ami
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.public_sg.id ]
        subnet_id                     =     aws_subnet.privatesubnet1.id  
        
}





resource  "aws_instance"  "bastion" {
    
        ami                           =     var.ami
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.bastion.id ]
        subnet_id                     =     aws_subnet.publicsubnet1.id  
}

 


 


resource  "aws_instance"  "jenkins" {

        ami                           =     var.ami
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.private_sg.id ]
        subnet_id                     =     aws_subnet.publicsubnet2.id
        
}



resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.publicsubnet1.id , aws_subnet.publicsubnet2.id]

}

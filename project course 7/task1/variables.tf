 

variable "aws_region" {
   
  type = string
  default = "us-east-1"
}

variable "publicsubnet1" {
        type            = map
        default = {
                "cidr"  = "10.1.101.0/24"
		"az"	= "us-east-1a"
        }

}


variable "ami" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}


variable "vpc_cidr" {
        default = "10.0.0.0/16"
}



variable "publicsubnet2" {
        type            = map
        default = {
                "cidr"  = "10.1.102.0/24"
		"az"    = "us-east-1b"
        }

}


variable "privatesubnet1" {
        type            = map
        default = {
                "cidr"  = "10.1.1.0/24"
		"az"	= "us-east-1a"
        }

}

variable "privatesubnt2" {
        type            = map
        default = {
                "cidr"  = "10.1.2.0/24"
		"az"	= "us-east-1b"
        }

}


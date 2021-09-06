output "app public ip" {
        value = aws_instance.app.public_ip
}


output "app private ip" {
        value = aws_instance.app.private_ip

}


output "bastion public ip" {
        value = aws_instance.bastion.public_ip
}




output "BastionIP" {
  value = aws_instance.bastion.public_ip
}

output "jenkins private ip" {
        value = aws_instance.jenkins.private_ip

}






output "InternetGateway" {
  value = aws_internet_gateway.igw.arn
}




output "LoadBalancer" {
  value = aws_lb.alb.arn
}


 




output "Admin_ip" {
  value = aws_eip.admin.public_ip
}

output "rhel_private_ip" {
    value = aws_instance.RHEL.private_ip
}

output "debian_private_ip" {
    value = aws_instance.Debian.private_ip
  
}

output "debian_name" {
    value = aws_instance.Debian.tags["Name"]
}


output "rhel_name" {
    value = aws_instance.RHEL.tags["Name"]
}


output "admin" {
    value = aws_instance.Admin.tags["Name"]
}


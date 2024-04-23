output "security_group_id" {
  value       = aws_security_group.sg_public.id
  description = "The ID of the security group"
}

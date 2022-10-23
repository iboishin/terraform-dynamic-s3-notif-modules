# output "all_permissions" {
#     value = aws_lambda_permission.allow_bucket_config
# }

# output "all_permission_ids" {
#     value = { for uc, group in aws_lambda_permission.allow_bucket_config : uc => group.statement_id }
# }


# output "lambda_arn" {
#   value = aws_s3_bucket_notification.s3_bucket_notification
# }
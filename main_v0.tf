# ##################################################
# ################ LAMBDA FUNCTION #################
# ##################################################

# resource "aws_iam_role" "iam_for_lambda_dash" {
#   name = "analytics-lambda-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# data "archive_file" "lambda_code_analytics" {
#   type        = "zip"
#   source_file = "source/analytics/lambda_function.py"
#   output_path = "source/analytics.zip"
# }

# resource "aws_lambda_function" "lambda_function_analytics" {
#   function_name = "analytics"
#   description   = "Lambda function to transform raw json attendance configuration files into csv files"
#   role          = aws_iam_role.iam_for_lambda_dash.arn
#   filename      = "source/analytics.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_analytics.output_base64sha256

#   runtime = "python3.9"

# }

# resource "aws_lambda_function" "lambda_function_dashboard" {
#   function_name = "dashboard"
#   description   = "Lambda function to transform raw json attendance configuration files into csv files"
#   role          = aws_iam_role.iam_for_lambda_dash.arn
#   filename      = "source/analytics.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_analytics.output_base64sha256

#   runtime = "python3.9"

# }


# ##################################################
# ################### S3 BUCKET ####################
# ##################################################
# # Necessary for raw data files
# resource "aws_s3_bucket" "raw_bucket" {
#   bucket = "mb-analytics"
# }

# resource "aws_s3_bucket_acl" "raw_bucket" {
#   bucket = aws_s3_bucket.raw_bucket.id
#   acl    = "private"
# }


# ##################################################
# #################### S3 NOTIF ####################
# ##################################################
# resource "aws_s3_bucket_notification" "s3_bucket_notification" {
#   bucket = "mb-analytics"

#   dynamic "lambda_function" {
#     for_each = toset(var.use_case_s3)

#     content {
#       lambda_function_arn = aws_lambda_function.lambda_function_analytics.arn
#       events              = ["s3:ObjectCreated:*"]
#       filter_suffix       = "${lambda_function.value}.csv"
#     }
#   }

# #   dynamic "topic" {
# #     for_each = toset(var.use_case_sns)

# #     content {
# #       topic_arn           = format("aws_sns_topic.dash-raw-s3-%s-event-topic.arn", each.sns.value)
# #       events              = ["s3:ObjectCreated:*"]
# #       filter_suffix       = "${each.key}.json"
# #     }
# #   }

#   depends_on = [
#     aws_lambda_permission.allow_bucket_config
#   ]
# }


# resource "aws_lambda_permission" "allow_bucket_config" {
#   for_each = toset(var.use_case_s3)

#   statement_id  = "AllowExecutionFromS3Bucket${each.value}"
#   action        = "lambda:InvokeFunction"
#   function_name = "${each.value}"
#   # function_name = aws_lambda_function.lambda_function_analytics.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = "arn:aws:s3:::mb-analytics"
# }

# # resource "aws_lambda_permission" "allow_invocation_from_sns" {
# #   for_each = toset(var.use_case_sns) 
# #   statement_id  = "AllowExecutionFromSNS"
# #   action        = "lambda:InvokeFunction"
# #   function_name = "aws_lambda_function.lambda_dash_std_${each.value}-event-topic.arn"
# #   principal     = "sns.amazonaws.com"
# #   source_arn    = "aws_sns_topic.dash-raw-s3-${each.value}-event-topic.arn"
# # }

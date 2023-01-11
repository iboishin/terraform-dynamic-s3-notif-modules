# ##################################################
# ################## LAMBDA ROLE ###################
# ##################################################

# ## Role for Lambda Functions
# resource "aws_iam_role" "iam_for_lambda_analytics" {
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

# resource "aws_iam_policy" "iam_for_lambda_s3" {
#   name = "analytics-lambda-role-s3-policy"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:GetObject*"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:s3:::mb-analytics",
#         "arn:aws:s3:::mb-analytics/*"
#       ]
#     }
#   ]
# }
# EOF
# }

# # Needed for S3 access
# resource "aws_iam_role_policy_attachment" "iam_for_lambda_s3" {
#   role       = aws_iam_role.iam_for_lambda_analytics.name
#   policy_arn = aws_iam_policy.iam_for_lambda_s3.arn
# }

# # Needed for logs
# resource "aws_iam_role_policy_attachment" "iam_for_lambda_logs" {
#   role       = aws_iam_role.iam_for_lambda_analytics.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# ##################################################
# ################ LAMBDA FUNCTIONS ################
# ##################################################

# ## Zip code for Lambda Functions
# data "archive_file" "lambda_code_seo" {
#   type        = "zip"
#   source_file = "source/seo/lambda_function.py"
#   output_path = "source/seo.zip"
# }

# data "archive_file" "lambda_code_sea" {
#   type        = "zip"
#   source_file = "source/sea/lambda_function.py"
#   output_path = "source/sea.zip"
# }

# data "archive_file" "lambda_code_website_events" {
#   type        = "zip"
#   source_file = "source/website_events/lambda_function.py"
#   output_path = "source/website_events.zip"
# }

# data "archive_file" "lambda_code_website_sessions" {
#   type        = "zip"
#   source_file = "source/website_sessions/lambda_function.py"
#   output_path = "source/website_sessions.zip"
# }

# ## Deploy Lambda Functions
# resource "aws_lambda_function" "seo" {
#   function_name = "seo"
#   description   = "Lambda function to transform seo data"
#   role          = aws_iam_role.iam_for_lambda_analytics.arn
#   filename      = "source/seo.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_seo.output_base64sha256

#   runtime = "python3.9"

# }

# resource "aws_lambda_function" "sea" {
#   function_name = "sea"
#   description   = "Lambda function to transform sea data"
#   role          = aws_iam_role.iam_for_lambda_analytics.arn
#   filename      = "source/sea.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_sea.output_base64sha256

#   runtime = "python3.9"

# }

# resource "aws_lambda_function" "website_events" {
#   function_name = "website_events"
#   description   = "Lambda function to transform website_events data"
#   role          = aws_iam_role.iam_for_lambda_analytics.arn
#   filename      = "source/website_events.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_website_events.output_base64sha256

#   runtime = "python3.9"

# }


# resource "aws_lambda_function" "website_sessions" {
#   function_name = "website_sessions"
#   description   = "Lambda function to transform website_sessions data"
#   role          = aws_iam_role.iam_for_lambda_analytics.arn
#   filename      = "source/website_sessions.zip"
#   handler       = "lambda_function.lambda_handler"
#   memory_size   = 256
#   timeout       = 30

#   source_code_hash = data.archive_file.lambda_code_website_sessions.output_base64sha256

#   runtime = "python3.9"

# }

# ##################################################
# ################### SNS TOPIC ####################
# ##################################################

# resource "aws_sns_topic" "website" {
#   name = "website"

#   policy = jsonencode(
#   {
#     "Version":"2012-10-17",
#     "Statement":[
#       {
#         "Effect": "Allow",
#         "Principal": {"Service":"s3.amazonaws.com"},
#         "Action": "SNS:Publish",
#         "Resource":  "arn:aws:sns:*:*:website",
#         "Condition":{
#             "ArnEquals":{"aws:SourceArn":"arn:aws:s3:::mb-analytics"}
#         }
#       }
#     ]
#   }
#   )
# }


# ##################################################
# ############### SNS SUBSCRIPTIONS ################
# ##################################################

# resource "aws_sns_topic_subscription" "lambda_subscription_to_sns_website_events" {
#   topic_arn = aws_sns_topic.website.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.website_events.arn

#   depends_on = [
#     aws_sns_topic.website
#   ]
# }

# resource "aws_sns_topic_subscription" "lambda_subscription_to_sns_website_sessions" {
#   topic_arn = aws_sns_topic.website.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.website_sessions.arn

#   depends_on = [
#     aws_sns_topic.website
#   ]
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
#   bucket = aws_s3_bucket.raw_bucket.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.seo.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_suffix       = "seo.csv"
#   }

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.sea.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_suffix       = "sea.csv"
#   }

#   topic {
#     topic_arn     = aws_sns_topic.website.arn
#     events        = ["s3:ObjectCreated:*"]
#     filter_suffix = "website.csv"
#   }

#   depends_on = [
#     aws_lambda_permission.allow_bucket_config_seo,
#     aws_lambda_permission.allow_bucket_config_sea,
#     aws_lambda_permission.allow_invocation_from_sns_website_events,
#     aws_lambda_permission.allow_invocation_from_sns_website_sessions,
#     aws_sns_topic.website
#   ]
# }

# ## Permissions to invoke Lambda Function
# resource "aws_lambda_permission" "allow_bucket_config_seo" {
#   statement_id  = "AllowExecutionFromS3Bucketseo"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.seo.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.raw_bucket.arn
# }

# resource "aws_lambda_permission" "allow_bucket_config_sea" {
#   statement_id  = "AllowExecutionFromS3Bucketsea"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.sea.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.raw_bucket.arn
# }

# resource "aws_lambda_permission" "allow_invocation_from_sns_website_events" {
#   statement_id  = "AllowExecutionFromSNSWebsiteEvents"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.website_events.arn
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.website.arn
# }

# resource "aws_lambda_permission" "allow_invocation_from_sns_website_sessions" {
#   statement_id  = "AllowExecutionFromSNSWebsiteSessions"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.website_sessions.arn
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.website.arn
# }

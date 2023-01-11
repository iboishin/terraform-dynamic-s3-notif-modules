##################################################
################## LAMBDA ROLE ###################
##################################################

## Role for Lambda Functions
resource "aws_iam_role" "iam_for_lambda_analytics" {
  name = "analytics-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_for_lambda_s3" {
  name = "analytics-lambda-role-s3-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::mb-analytics",
        "arn:aws:s3:::mb-analytics/*"
      ]
    }
  ]
}
EOF
}

# Needed for S3 access
resource "aws_iam_role_policy_attachment" "iam_for_lambda_s3" {
  role       = aws_iam_role.iam_for_lambda_analytics.name
  policy_arn = aws_iam_policy.iam_for_lambda_s3.arn
}

# Needed for logs
resource "aws_iam_role_policy_attachment" "iam_for_lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_analytics.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


##################################################
################ LAMBDA FUNCTIONS ################
##################################################

## only archive and function; can have one module loop for all four functions
## just need to consider how it is used in S3 notifications

module "lambda_s3" {
  source = "./modules/lambda_function"
  for_each         = toset(var.use_case_s3)

  lambda-role-arn  = aws_iam_role.iam_for_lambda_analytics.arn
  function-name    = each.value
  description      = "Lambda function to transform ${each.value} data"
  lambda-code-path = "source/${each.value}/lambda_function.py"
  lambda-zip-path  = "source/${each.value}.zip"

}

module "lambda_sns" {
  source = "./modules/lambda_function"
  for_each = toset(var.use_case_sns.*.lambda_func)

  lambda-role-arn  = aws_iam_role.iam_for_lambda_analytics.arn
  function-name    = each.value
  description      = "Lambda function to transform ${each.value} data"
  lambda-code-path = "source/${each.value}/lambda_function.py"
  lambda-zip-path  = "source/${each.value}.zip"

}


##################################################
######### S3 BUCKET + S3 and SNS NOTIF ###########
##################################################

module "raw_bucket" {
  source       = "./modules/s3"
  bucket_name  = var.bucket_name
  use_case_s3  = var.use_case_s3
  use_case_sns = var.use_case_sns
  aws_id = var.aws_id
}
##################################################
################ LAMBDA FUNCTION #################
##################################################

resource "aws_iam_role" "iam_for_lambda_dash" {
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

module "lambda_s3" {
  source = "./modules/lambda_function"

  for_each         = toset(var.use_case_s3)
  lambda-role-arn  = aws_iam_role.iam_for_lambda_dash.arn
  function-name    = each.value
  description      = "Test function for ${each.value}"
  lambda-code-path = "source/${each.value}/lambda_function.py"
  lambda-zip-path  = "source/${each.value}.zip"

}

module "lambda_sns" {
  source = "./modules/lambda_function"

  for_each = { for idx, uc in var.use_case_sns : uc.lambda_func => uc }

  lambda-role-arn  = aws_iam_role.iam_for_lambda_dash.arn
  function-name    = each.value.lambda_func
  description      = "Test function for ${each.value.lambda_func}"
  lambda-code-path = "source/${each.value.lambda_func}/lambda_function.py"
  lambda-zip-path  = "source/${each.value.lambda_func}.zip"

}


##################################################
############### S3 BUCKET + NOTIF ################
##################################################

module "raw_bucket" {
  source       = "./modules/s3"
  bucket_name  = "mb-analytics"
  use_case_s3  = var.use_case_s3
  # use_case_sns = var.use_case_sns
  aws_id = var.aws_id
}
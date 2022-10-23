##################################################
########### Raw Data Lambda Functions ############
##################################################
data "archive_file" "lambda_code_zip" {
  type        = "zip"
  source_file = var.lambda-code-path
  output_path = var.lambda-zip-path
}


##################################################
########### Raw Data Lambda Functions ############
##################################################

# Attendance config lambda function
resource "aws_lambda_function" "lambda_dash" {
  function_name = var.function-name
  description   = var.description
  role          = var.lambda-role-arn
  filename      = var.lambda-zip-path
  handler       = "lambda_function.lambda_handler"
  layers        = [ "arn:aws:lambda:eu-west-3:336392948345:layer:AWSDataWrangler-Python39:3" ]
  memory_size   = 256
  timeout       = 30

  source_code_hash = data.archive_file.lambda_code_zip.output_base64sha256

  runtime = "python3.9"

}

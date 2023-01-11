##################################################
############### Create S3 Bucket ################
##################################################

resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "raw_bucket" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

##################################################
################### SNS TOPIC ####################
##################################################

resource "aws_sns_topic" "dash-s3-event-topic" {
  for_each = toset(var.use_case_sns.*.sns_topic)
  
  name = each.value
  policy = jsonencode(
  {
    "Version":"2012-10-17",
    "Statement":[
      {
        "Effect": "Allow",
        "Principal": {"Service":"s3.amazonaws.com"},
        "Action": "SNS:Publish",
        "Resource":  "arn:aws:sns:*:*:${each.value}",
        "Condition":{
            "ArnEquals":{"aws:SourceArn":"arn:aws:s3:::${var.bucket_name}"}
        }
      }
    ]
  }
  )
}

resource "aws_sns_topic_subscription" "dash-s3-event-to-lambda" {
  for_each = {for idx, uc in var.use_case_sns: uc.lambda_func => uc}

  topic_arn = "arn:aws:sns:eu-west-3:${var.aws_id}:${each.value.sns_topic}"
  protocol  = "lambda"
  endpoint  = "arn:aws:lambda:eu-west-3:${var.aws_id}:function:${each.value.lambda_func}"

  depends_on = [
    aws_sns_topic.dash-s3-event-topic
  ]
}


##################################################
############### Raw Data Triggers ################
##################################################

resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = var.bucket_name
  
  dynamic "lambda_function" {
    for_each = toset(var.use_case_s3)

    content {
      lambda_function_arn = "arn:aws:lambda:eu-west-3:${var.aws_id}:function:${lambda_function.value}"
      events              = ["s3:ObjectCreated:*"]
      filter_suffix       = "${lambda_function.value}.csv"
    }

  }

  dynamic "topic" {
    for_each = toset(var.use_case_sns.*.sns_topic)

    content {
      topic_arn           = "arn:aws:sns:eu-west-3:${var.aws_id}:${topic.value}"
      events              = ["s3:ObjectCreated:*"]
      filter_suffix       = "${topic.value}.csv"
    }
  }

  depends_on = [
    aws_lambda_permission.allow_invocation_from_s3,
    aws_lambda_permission.allow_invocation_from_sns,
    aws_sns_topic.dash-s3-event-topic
  ]

}


# Permissions for lambda triggers

resource "aws_lambda_permission" "allow_invocation_from_s3" {
  for_each = toset(var.use_case_s3)

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

resource "aws_lambda_permission" "allow_invocation_from_sns" {
  ## naming the element instead of simply using the index so that the naming is clear
  for_each = {for idx, uc in var.use_case_sns: uc.lambda_func => uc}

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.lambda_func}"
  principal     = "sns.amazonaws.com"
  source_arn    = "arn:aws:sns:::${each.value.sns_topic}"
}
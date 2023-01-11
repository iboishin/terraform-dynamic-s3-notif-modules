variable "aws_id" {
  type        = string
  description = "AWS account id"
}

variable "bucket_name" {
  type        = string
}

## setting defaults on my use_case attributes to allow the creation of s3 buckets without notifications
variable use_case_s3 {
  type = list(string)
  description = "List of S3 use cases"
  default = []
}

variable use_case_sns {
  type = list(object({
    lambda_func = string
    sns_topic = string
  }))
  description = "Dictionary of containing elements for each use case having an SNS notification. 'lambda_func' refers to the name of the lambda function. 'sns_topic' refers to the name of the SNS topic."
  default = []
}
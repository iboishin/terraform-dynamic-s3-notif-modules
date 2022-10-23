variable "aws_id" {
  type        = string
}

variable "bucket_name" {
  type        = string
}

## setting defaults on my use_case attributes to allow the creation of s3 buckets without notifications
variable use_case_s3 {
  type = list(string)
  description = "List of names"
  default = []
}

variable use_case_sns {
  type = list(object({
    lambda_func = string
    sns_topic = string
  }))
  description = "Dictionary of [{lambda_func = 'use case lambda', sns_topic = 'sns topic'}]"
  default = []
}
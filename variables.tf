variable "bucket_name" {
  type    = string
  default = "mb-analytics"
}

variable "use_case_s3" {
  type    = list(string)
  default = ["seo", "sea"]
}

variable "use_case_sns" {
  type = list(object({
    lambda_func = string
    sns_topic = string
  }))
  default = [
    {
      lambda_func = "website_sessions"
      sns_topic   = "website"
    },
    {
      lambda_func = "website_events"
      sns_topic   = "website"
    }
  ]
}
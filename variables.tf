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
      lambda_func = "website"
      sns_topic   = "website"
    }
  ]
}
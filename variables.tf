variable "use_case_s3" {
  type    = list(string)
  default = ["analytics", "dashboard"]
}

variable "use_case_sns" {
  type = list(object({
    lambda_func = string
    sns_topic = string
  }))
  default = [
    {
      lambda_func = "visualisation"
      sns_topic   = "visualisation"
    },
    {
      lambda_func = "picture"
      sns_topic   = "visualisation"
    }
  ]
}
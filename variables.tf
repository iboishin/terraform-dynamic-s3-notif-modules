variable "use_case_s3" {
  type    = list(any)
  default = ["analytics", "dashboard"]
}

variable "use_case_sns" {
  type = list(any)
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
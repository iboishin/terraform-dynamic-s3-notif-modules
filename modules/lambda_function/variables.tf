variable "lambda-role-arn" {
  type        = string
  description = "IAM role used for lambda execution"
}

variable "function-name" {
  type        = string
  description = "Name for lambda function"
}
variable "description" {
  type        = string
  description = "Description of lambda function"
}

variable "lambda-code-path" {
  type        = string
  description = "Location of code for lambda function"
}

variable "lambda-zip-path" {
  type        = string
  description = "Location of zip file for lambda function"
}
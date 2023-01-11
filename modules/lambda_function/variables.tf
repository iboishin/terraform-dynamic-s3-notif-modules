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

variable "memory_size" {
  type    = number
  default = 256
}

variable "timeout" {
  type    = number
  default = 30
}
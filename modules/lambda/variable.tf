variable "vpc_id" {
  type = string
}

variable "function_name" {
  type = string
}

variable "lambda_timeout" {
  type = number
}

variable "image-uri" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "host_ip" {
  type = string
}

variable "user" {
  type = string
}

variable "password" {
  type = string
}

variable "database_name" {
  type = string
}

variable "execution_arn" {
  type = string
}

variable "path_parts" {
  type = any
}
variable "name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnets_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}
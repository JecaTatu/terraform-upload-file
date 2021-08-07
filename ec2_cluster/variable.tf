variable "instance_profile_name" {
  type = string
  default = null
}

variable "cluster_name" {
  type = string
}

variable "instance_count" {
  type = number
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

variable "lb_security_group" {
  type = string
}
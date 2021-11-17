variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "server_port" {
  description = "Http port for busybox"
  type        = number
}

variable "kp" {
  description = "Key pair name"
  type        = string
}
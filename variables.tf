variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "workstation_ip" {
  type = string
}

variable "amis" {
  type = map(any)
  default = {
    "us-east-1" : "ami-0dfcb1ef8550277af"
    "us-west-1" : "ami-0cd7323ab3e63805f"
  }
}
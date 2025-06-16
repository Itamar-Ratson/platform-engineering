#general

variable "region" {
  type    = string
  default = "eu-north-1"
}

#eks cluster

variable "cluster_name" {
  type    = string
  default = "EKS_Cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.32"
}


#tags

variable "environment" {
  type    = string
  default = "dev"
}


#vpc

variable "vpc_id" {
  type    = string
  default = "vpc-004909e3659ac403e"
}

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-095cbe026b14e103c", "subnet-0d5145d51bcc8c071", "subnet-0c6bcd3649966a892"]
}

#node groups

variable "instance_types" {
  type    = list(string)
  default = ["t3.micro"]
}

variable "min_nodes" {
  type = number
  default = 3
}

variable "max_nodes" {
  type = number
  default = 3
}

variable "desired_nodes" {
  type = number
  default = 3
}

variable "vpc_name" {
  type = map(any)
  default = {
    name = "gurada_vpc"
  }
}

variable "project_name" {
  default = "garuda"
}

variable "environment" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "common_tags" {
  type = map(any)
  default = {
    project     = "garuda"
    environment = "dev"
    terraform   = "true"
    automation  = "true"
  }
}

# variable "public_subnet_cidrs" {
#     type = list
#     validation {
#         condition = length(var.public_subnet_cidrs) == 2
#         error_message = "Please provide 2 valid public subnet CIDR"
#     }
# }


variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24","10.0.2.0/24"]
}


variable "private_subnet_cidr" {
  type = list(string)
  default = [ "10.0.3.0/24","10.0.4.0/24" ]
}

variable "database_subnet_cidr" {
  type = list(string)
  default = [ "10.0.5.0/24","10.0.6.0/24" ]
}
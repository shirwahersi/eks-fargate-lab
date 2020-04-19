variable "cluster_name" {
  description = "The prefix used in the names of most infraestructure resources"
  default     = "shirwalab-eks"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  default     = "dev"
  type        = string
}

// VPC

variable "region" {
  description = "The AWS region where the infraestructure will be located"
  default     = "eu-west-1"
  type        = string
}

variable "azs" {
  description = "The availability zones where the infraestructure will be located"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CIDR block for the cloud VPC"
  default     = "172.16.0.0/16"
  type        = string
}

variable "private_subnets_cidrs" {
  description = "The CIDRs of private subnets of the cloud VPC. The default values allow 4094 hosts per subnet"
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  type        = list(string)
}

variable "public_subnets_cidrs" {
  description = "The CIDRs of public subnets of the cloud VPC. The default values allow 4094 hosts per subnet"
  default     = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  type        = list(string)
}

// EKS

variable "cluster_version" {
  default     = "1.15"
  type        = string
  description = "Kubernetes version to use for the EKS cluster.	"
}

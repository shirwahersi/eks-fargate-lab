terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = var.region
}


locals {
  cluster_name      = "${var.cluster_name}-${var.environment}"
}

locals {
  map_roles = [
    {
      rolearn  = module.FargateExecutionRole.this_iam_role_arn
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
    },
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "rolearn: arn:aws:iam::414336264239:role/shirwalab-eks-dev-fargate-execution-role"
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes", "system:node-proxier"]
    },
  ]
}


#------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------

module "vpc" {
  source                      = "terraform-aws-modules/vpc/aws"
  version                     = "~> 2.0"
  name                        = "${local.cluster_name}-vpc"
  cidr                        = var.vpc_cidr
  azs                         = var.azs
  private_subnets             = var.private_subnets_cidrs
  public_subnets              = var.public_subnets_cidrs
  enable_nat_gateway          = true
  single_nat_gateway          = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

#------------------------------------------------------------------------
# EKS
#------------------------------------------------------------------------

data "aws_eks_cluster" "cluster" {
  name                        = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name                        = module.eks.cluster_id
}

provider "kubernetes" {
  host                        = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate      = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                       = data.aws_eks_cluster_auth.cluster.token
  load_config_file            = false
  version                     = "~> 1.11"
}

module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "v11.0.0"
  cluster_name                = local.cluster_name
  cluster_version             = var.cluster_version
  subnets                     = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  enable_irsa                 = true
  write_kubeconfig            = false
  cluster_enabled_log_types   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  node_groups = {
    np1 = {
      desired_capacity = 1
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t2.medium"
      k8s_labels = {
        Environment = var.environment
      }
    }
  }
  map_roles                   = local.map_roles

  tags = {
    environment               = var.environment
  }
}

// Fargate profile

module "FargateExecutionRole" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version                       = "~> v2.0"
  create_role                   = true
  role_name                     = format("%s-fargate-execution-role", local.cluster_name)
  role_requires_mfa             = false
  trusted_role_services         = ["eks-fargate-pods.amazonaws.com"]
  custom_role_policy_arns       = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
}

resource "aws_eks_fargate_profile" "fargate_profile_default" {
  cluster_name                  = local.cluster_name
  fargate_profile_name          = format("%s-fargate-default", local.cluster_name)
  pod_execution_role_arn        = module.FargateExecutionRole.this_iam_role_arn
  subnet_ids                    = module.vpc.private_subnets

  selector {
    namespace                   = "default"
    labels                      = { compute-type = "fargate" }
  }
  depends_on = [ module.eks ]
}
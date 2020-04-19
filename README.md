# EKS Fargate

AWS Fargate is a technology that provides on-demand, right-sized compute capacity for containers. With AWS Fargate, you no longer have to provision, configure, or scale groups of virtual machines to run containers. This removes the need to choose server types, decide when to scale your node groups, or optimize cluster packing.

AWS Fargate with Amazon EKS is currently only available in the following Regions:

| Region Name | Region |
|---|---|
| US East (Ohio) | us-east-2 |
| US East (N. Virginia) | us-east-1 |
| Asia Pacific (Tokyo) | ap-northeast-1 |
| EU (Ireland) | eu-west-1 |

There are currently a few limitations that you should be aware of:

* There is a maximum of 4 vCPU and 30Gb memory per pod.
* Currently there is no support for stateful workloads that require persistent volumes or file systems. Support for EFS is coming soon - https://github.com/aws/containers-roadmap/issues/826
* You cannot run Daemonsets, Privileged pods, or pods that use HostNetwork or HostPort.
* The only load balancer you can use is an Application Load Balancer.


## Setup ECS Cluster

![](assets/fargate-mix.png)

### Installing the Client Tools

**Download terraform**

```
wget https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_darwin_amd64.zip
unzip terraform_0.12.23_darwin_amd64.zip
sudo mv terraform /usr/local/bin/terraform
```

**Download aws-iam-authenticator**

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/darwin/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
```

### Provision EKS Cluster

Clone github repo

```
git clone https://github.com/shirwahersi/eks-fargate-lab.git
cd eks-fargate-lab/terraform
```

```
terraform init
terraform plan
terraform apply
```

Create kubeconfig file:

```
terraform output kubectl_config > ${HOME}/.kube/crafter-eks
export KUBECONFIG=${HOME}/.kube/crafter-eks
```


# Useful Resources

* [AWS re:Invent 2019: Running Kubernetes Applications on AWS Fargate](https://www.youtube.com/watch?v=m-3tMXmWWQw)
* [eksworkshop.com](https://eksworkshop.com/)
* [EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
* https://bcouetil.gitlab.io/academy/BP-kubernetes.html#full-project-example
* https://itnext.io/eks-fargate-extensibility-of-kubernetes-serverless-benefits-77599ac1763




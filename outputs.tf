

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.k8s-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: ${aws_iam_user.kube-user.arn}
      username: ${aws_iam_user.kube-user.name}
      groups:
        - system:masters
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.k8s-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.k8s-cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

#output "config_map_aws_auth" { value = "${local.config_map_aws_auth}" }
#output "kubeconfig" { value = "${local.kubeconfig}" }

resource "local_file" "aws-auth-file" {
  content  = "${local.config_map_aws_auth}"
  filename = "./output_files/aws-auth-config-map.yaml"
}

resource "local_file" "kube-config-file" {
  content  = "${local.kubeconfig}"
  filename = "./output_files/kube-config.yaml"
}


output "users" { value = "${join(",", aws_iam_access_key.kube-user-key.*.user)}" }
output "users_arn" { value = "${aws_iam_user.kube-user.arn}" }
output "access_ids" { value = "${join(",", aws_iam_access_key.kube-user-key.*.id)}" }
output "secret_keys" { value = "${join(",", aws_iam_access_key.kube-user-key.*.secret)}" }

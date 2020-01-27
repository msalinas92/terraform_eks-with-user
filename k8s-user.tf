
resource "aws_iam_user" "kube-user" {
  name = "kube-user"
  path        = "/"
  tags = {
    User = "kubernetes"
  }
}

resource "aws_iam_access_key" "kube-user-key" {
  count = "${length(split(",", "kube-user"))}"
  user  = "${element(aws_iam_user.kube-user.*.name, count.index)}"
}

resource "aws_iam_policy" "kube-policy" {
  name        = "kube-policy"
  path        = "/"
  description = "Politica de lectura de cluster de kubernetes"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeFargateProfile",
                "eks:ListTagsForResource",
                "eks:DescribeUpdate",
                "eks:ListUpdates",
                "eks:DescribeCluster"
            ],
            "Resource": "${aws_eks_cluster.k8s-cluster.arn}"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "eks:ListClusters",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "kube-policy-attach" {
  user       = "${aws_iam_user.kube-user.name}"
  policy_arn = "${aws_iam_policy.kube-policy.arn}"
}


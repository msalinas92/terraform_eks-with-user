
resource "aws_iam_role" "k8s-node" {
  name = "terraform-eks-k8s-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.k8s-node.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.k8s-node.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.k8s-node.name}"
}

resource "aws_eks_node_group" "k8s-node-group" {
  cluster_name    = "${aws_eks_cluster.k8s-cluster.name}"
  node_group_name = "k8s-node-group"
  node_role_arn   = "${aws_iam_role.k8s-node.arn}"
  subnet_ids      = "${aws_subnet.k8s-subnet.*.id}"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.k8s-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.k8s-node-AmazonEC2ContainerRegistryReadOnly"
  ]
}

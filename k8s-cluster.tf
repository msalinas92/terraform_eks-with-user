
resource "aws_iam_role" "k8s-cluster" {
  name = "terraform-eks-k8s-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.k8s-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "k8s-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.k8s-cluster.name}"
}

resource "aws_security_group" "k8s-cluster" {
  name        = "terraform-eks-k8s-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.k8s-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "k8s-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.k8s-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "k8s-cluster" {
  name     = "${var.cluster-name}"
  role_arn = "${aws_iam_role.k8s-cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.k8s-cluster.id}"]
    subnet_ids         = "${aws_subnet.k8s-subnet.*.id}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.k8s-cluster-AmazonEKSServicePolicy"
  ]
}

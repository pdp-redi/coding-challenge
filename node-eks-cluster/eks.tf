# Define the EKS cluster
resource "aws_eks_cluster" "eks" {
  name     = "eks-cluster"
  version  = "1.30"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy, aws_iam_role_policy_attachment.AmazonEKSVPCResourceController]
}

# create Node Group
resource "aws_eks_node_group" "node_group_general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "node_group_general"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  version         = "1.30"

  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

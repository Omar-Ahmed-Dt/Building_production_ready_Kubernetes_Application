locals {
  cluster_name = "cluster-prod"
  
  tags = {
    "karpenter.sh/discovery" = local.cluster_name
    "author"                 = "Poseidon"
  }
}

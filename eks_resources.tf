# creates the necessary AWS IAM role and policies that the Cet Manager service account will assume
# Manages certificates, needs access to Route 53 for DNS-based validation
module "cert_manager_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.32.0"

  role_name = "cert-manager-irsa-role"

#   provider_url = module.cluster.oidc_provider_url
  provider_url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:cert-manager"
  ]

  tags = local.tags
}

# creates the necessary AWS IAM role and policies that the External Secrets service account will assume
# Syncs secrets from AWS Secrets Manager and SSM Parameter Store with Kubernetes secrets, and needs read access to those services.
module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.32.0"

  role_name = "external-secrets-irsa-role"

#   provider_url = module.cluster.oidc_provider_url
  provider_url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:external-secrets:secret-store"
  ]

  tags = local.tags
}

# Deploy ESO
resource "helm_release" "eso" {
  name       = "external-secrets"
  create_namespace = true
  namespace  = "external-secrets"
  repository = "https://external-secrets.io"
  chart      = "external-secrets"
  # version    = "0.6.1"
  timeout    = 300
  atomic     = true
  depends_on = [aws_eks_cluster.eks_cluster]

}

# Deploy Cert Manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  create_namespace = true
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  # version          = "1.12.0"
  timeout          = 300
  atomic           = true

# Fixed the values block, ensuring that installCRDs: true is correctly formatted as YAML.
  values = [
    <<EOF
installCRDs: true
EOF
  ]
  depends_on = [aws_eks_cluster.eks_cluster]

}

# Deploy Ingress NGINX
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  create_namespace = true
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  # version          = "4.0.5"
  timeout          = 300
  atomic           = true

  values = [
    <<EOF
controller:
  podSecurityContext:
    runAsNonRoot: true
service:
  enabled: true
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
  enableHttp: true
  enableHttps: true
EOF
  ]
  depends_on = [aws_eks_cluster.eks_cluster]

}

# Deploy ArgoCD
resource "helm_release" "argocd" {
  name             = "argo-cd"
  namespace        = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "4.5.1"
  timeout          = 300
  atomic           = true
  create_namespace = true

  values = [
    <<EOF
nameOverride: argo-cd
redis-ha:
  enabled: false
controller:
  replicas: 1
server:
  replicas: 1
reposerver:
  replicas: 1
applicationSet:
  replicaCount: 1

server:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
      service.beta.kubernetes.io/aws-load-balancer-internal: "false" # Set to "true" for internal NLB
    loadBalancerIP: null
    loadBalancerSourceRanges: []
EOF
  ]
}

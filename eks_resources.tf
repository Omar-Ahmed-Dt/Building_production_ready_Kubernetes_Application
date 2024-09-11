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

# Create ESO
resource "helm_release" "eso" {
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://external-secrets.io"
  chart      = "external-secrets"
  # version    = "0.6.1"
  timeout    = 300
  atomic     = true
}

# Create Cert Manager
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  # version          = "1.12.0"
  timeout          = 300
  atomic           = true
  create_namespace = true

# Fixed the values block, ensuring that installCRDs: true is correctly formatted as YAML.
  values = [
    <<EOF
installCRDs: true
EOF
  ]
}

# Create Ingress NGINX
resource "helm_release" "ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  # version          = "4.0.5"
  timeout          = 300
  atomic           = true
  create_namespace = true

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
}

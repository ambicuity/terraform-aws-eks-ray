provider "helm" {
  kubernetes {
    host                   = module.ray_eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.ray_eks_cluster.cluster_certificate_authority)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# Deploy the Kubernetes Cluster Autoscaler
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.43.2" # Compatible with K8s 1.31
  wait       = true
  timeout    = 300

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ray_eks_cluster.cluster_autoscaler_iam_role_arn
  }

  depends_on = [module.ray_eks_cluster]
}

# Deploy the KubeRay Operator
resource "helm_release" "kuberay_operator" {
  name             = "kuberay-operator"
  repository       = "https://ray-project.github.io/kuberay-helm/"
  chart            = "kuberay-operator"
  namespace        = "ray-system"
  create_namespace = true
  version          = "1.1.0"
  wait             = true
  timeout          = 300

  depends_on = [module.ray_eks_cluster]
}

resource "helm_release" "ray_cluster" {
  name      = "ray-cluster"
  chart     = "../../helm/ray"
  namespace = "ray-system"
  wait      = true
  timeout   = 300

  values = [
    <<-EOT
    cpuWorkers:
      replicas: 1
      minReplicas: 1
      maxReplicas: 3
    gpuWorkers:
      enabled: false
    gpuWorkerGroups:
      - groupName: inference
        replicas: 0
        minReplicas: 0
        maxReplicas: 2
        rayStartParams: {}
        resources:
          requests:
            cpu: "2"
            memory: "8Gi"
            nvidia.com/gpu: "1"
          limits:
            cpu: "4"
            memory: "16Gi"
            nvidia.com/gpu: "1"
        volumeMounts:
          - name: ray-tmp
            mountPath: /tmp/ray
        volumes:
          - name: ray-tmp
            emptyDir:
              medium: Memory
        nodeSelector:
          ray.io/resource-type: gpu
          gpu-group: inference
        tolerations:
          - key: nvidia.com/gpu
            operator: Equal
            value: "true"
            effect: NoSchedule
        topologySpreadConstraints: []
        labels:
          ray.io/node-type: worker
          ray.io/resource-type: gpu
          gpu-group: inference
          app: ray
          component: gpu-worker
        initContainers: []
      - groupName: training
        replicas: 0
        minReplicas: 0
        maxReplicas: 1
        rayStartParams: {}
        resources:
          requests:
            cpu: "8"
            memory: "32Gi"
            nvidia.com/gpu: "1"
          limits:
            cpu: "16"
            memory: "64Gi"
            nvidia.com/gpu: "1"
        volumeMounts:
          - name: ray-tmp
            mountPath: /tmp/ray
        volumes:
          - name: ray-tmp
            emptyDir:
              medium: Memory
        nodeSelector:
          ray.io/resource-type: gpu
          gpu-group: training
        tolerations:
          - key: nvidia.com/gpu
            operator: Equal
            value: "true"
            effect: NoSchedule
        topologySpreadConstraints: []
        labels:
          ray.io/node-type: worker
          ray.io/resource-type: gpu
          gpu-group: training
          app: ray
          component: gpu-worker
        initContainers: []
    EOT
  ]

  depends_on = [helm_release.kuberay_operator]
}

# Cluster Resilience Validation Suite

This directory contains executable scripts to empirically validate the mitigations built into this platform against a live Kubernetes cluster.

Synthetic logs are unconvincing. Run these scripts against your provisioned cluster to generate real-world metric evidence.

## Prerequisites

1.  Provision the cluster using the Terraform module:
    ```bash
    cd ../terraform
    terraform init
    terraform apply
    aws eks --region us-east-1 update-kubeconfig --name production-ray-cluster
    ```
2.  Install KubeRay operator (done via Helm in the module) and ensure worker nodes are available.
3.  Ensure `ray` and `kubernetes` python packages are installed locally:
    ```bash
    pip install ray[default] kubernetes
    ```

## Executable Validations

### 1. High Availability (HA) & MTTR Validation
Simulates a node loss/spot interruption and verifies that tasks recover and Ray Serve drops 0 requests (mitigating the legendary 502 error problem).
```bash
python ../workloads/ha_resilience_test.py
python ../workloads/chaos_test.py
```

### 2. CoreDNS Scale-out Verification
Triggers a massive 200-node scale-out event and verifies that the CoreDNS replica configuration prevents DNS DoS throttling.
```bash
chmod +x test_scale_event.sh
./test_scale_event.sh
```

### 3. GPU Pod Density Math Validation
Proves mathematically that the AWS VPC CNI Prefix Delegation fix is active, allowing `g4dn.xlarge` instances to host 100+ pods instead of the default 14.
```bash
chmod +x test_gpu_density.sh
./test_gpu_density.sh
```

### 4. Memory Stress Object Spilling Validation
Injects a heavy PyTorch-style data loading script that forcibly exceeds the Ray object store limit, verifying that Ray spills gracefully to the memory-backed `emptyDir` (`/tmp/ray`) rather than causing a Kubelet root disk `DiskPressure` node eviction.
```bash
python test_memory_spill.py
```

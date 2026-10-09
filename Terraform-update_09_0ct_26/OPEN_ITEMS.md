# Remaining validation before execution

1. Recover the exact module versions from the existing working directory `.terraform/modules/modules.json`; do not use init -upgrade. The provider lock file is preserved from the supplied source and must be compared with the current working copy.
2. Export full values of the tracked Karpenter and AWS Load Balancer Controller releases locally, compare them with this package, and reconcile differences before permitting Helm updates.
3. Run Terraform fmt and validate using the existing compatible Terraform installation and backend. Verify data-source/provider/module schemas; offline HCL parsing is not Terraform validate.
4. Only for plan review, set enable_baseline_plan=true and run a normal terraform plan with locking enabled. This package does not authorize apply. Never use -target to hide changes.
5. Reject and reconcile any destroy/replace actions, cluster encryption/access changes, launch-template generation changes, IAM policy differences or Helm rollout changes. A reviewed infrastructure no-change plan is the acceptance criterion; output additions may appear separately.
6. Recover full original configuration of the twelve retained EFS/SG/endpoint resources before removing ignore_changes=all. These declarations protect existing state resources but do not configure new replacement resources.
7. Karpenter NodePool/EC2NodeClass and workload affinity snapshots are reference manifests. Their Helm/GitOps ownership is separate; do not kubectl apply them or introduce duplicate Terraform ownership.

No imports are required for the 28 earlier candidates. Do not edit, push, or replace backend state manually. See STATE_RECONCILIATION.md.

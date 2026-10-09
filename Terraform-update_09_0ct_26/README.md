# BASIK current Terraform baseline — state-reconciled review package

This package updates the old source against supplied live AWS/Kubernetes exports and backend state serial 150. It preserves existing Terraform addresses. See STATE_RECONCILIATION.md and OPEN_ITEMS.md before use.

Included: current subnets, EKS configuration, managed node groups, seven add-ons, verified Karpenter IAM policies, pinned Helm chart versions, live Karpenter manifests, workload affinity references, and retention declarations for twelve resources missing from the old source.

The backend already tracks the 28 earlier import candidates; no re-import is needed. No remote state or infrastructure was changed. No raw state, saved plan, credentials, or obsolete local state is packaged.

The default review guard stops planning. After resolving the listed prerequisites, enable_baseline_plan=true permits plan inspection only. Terraform is unavailable in this environment, so provider validation and a no-change plan have not been run. This is not an apply-ready release.

## S3-only backend

backend.tf now uses native S3 locking (use_lockfile=true), with encrypt=true and the existing bucket/key unchanged. Read S3_BACKEND_SWITCH.md before reinitializing any runner. No DynamoDB table deletion is included.

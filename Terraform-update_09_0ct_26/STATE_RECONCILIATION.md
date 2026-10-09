# BASIK backend state reconciliation — 7 October 2026

The supplied read-only backend inventory has Terraform version 1.15.8, serial 150 and lineage 4ac7b28e-75c4-64a1-371c-8e456fc3e436. It contains 111 active managed resource instances. All 21 collection checks succeeded.

All 28 previously proposed import targets are already tracked at their existing addresses. No import commands are required for those resources. Remote state has not been edited, pushed or replaced. The obsolete local state is not included in this package. The address register is a filtered inventory, not a usable replacement state file.

## Confirmed ownership

- Live EKS encryption key: module.eks.module.kms.aws_kms_key.this[0], key 793ea5bf-4924-4fbe-ba84-86030a29b490. Preserve module ownership.
- Separate root aws_kms_key.eks: 8f910be4-e4a4-4292-b8c0-78f971dcab24. Retained; not assigned as the live cluster encryption key.
- Karpenter uses five existing root policy resources and five keyed attachments, not the historical IAM module-generated controller policy.
- Existing Helm releases are already tracked. Chart versions are Karpenter 1.14.0 and AWS Load Balancer Controller 3.4.3.
- Existing creator access entry remains ECC_Admin; it is explicitly declared to avoid substituting the identity running Terraform.
- Platform node group uses launch template version 3 while template default remains version 2. TEC and Spartans use version 2 with no explicit root disk mapping.
- Twelve EFS, security group and S3 endpoint resources absent from the old source are retained at their current addresses. Retention declarations freeze updates with ignore_changes=all and reject destruction. They are not complete reconstructed configurations.

## What remains

HCL parsing validates syntax only. Provider/module validation and a normal Terraform plan are still required. Complete Helm release values and exact previously resolved module versions were not supplied. Differences in tags, module defaults, launch-template fields and policy defaults must be resolved from a plan. Do not apply a plan containing deletion, replacement, IAM changes or Helm updates as part of baseline reconciliation.

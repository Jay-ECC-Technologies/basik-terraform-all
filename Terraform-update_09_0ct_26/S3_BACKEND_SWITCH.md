# Switch BASIK to S3-only backend locking

The existing bucket and state key are unchanged. No state migration, import or state push is required. DynamoDB is no longer configured by backend.tf. This edit has not been applied to the live environment and does not delete the existing DynamoDB table.

## Prerequisites

- Use Terraform 1.10 or newer everywhere; preferably keep the currently used compatible version 1.15.8. Existing required_version is already >= 1.10.0.
- Coordinate all workstations and CI/CD runners. No Terraform operation may be active during the switch. An old DynamoDB-only runner and a new S3-only runner do not share a lock. For a gradual migration, temporarily configure both use_lockfile=true and dynamodb_table="terraform-state" on upgraded runners until all runners support S3 locking, then remove dynamodb_table everywhere.
- Preserve existing S3 state access, bucket versioning and SSE-KMS permissions. The bucket uses SSE-KMS; encrypt=true does not change its default KMS key.
- Add the lock-object permissions from references/s3-lock-permissions-example.json to the existing Terraform execution policy if missing. This is an additive policy fragment, not a complete replacement policy. It targets the default workspace only; other workspaces require their corresponding prefixed lock paths.
- Remove DynamoDB settings from any external -backend-config files/arguments and CI/CD settings as well as source code.

## Reinitialize in the existing Terraform working directory

Do not run this package from an unrelated directory against production until the source reconciliation OPEN_ITEMS are resolved. To change only locking, copy backend.tf into the existing current source working directory and retain its module/provider lock information.

```bash
terraform version
terraform init -reconfigure
terraform state list
```

No -migrate-state is needed because bucket/key/region remain unchanged. Do not use init -upgrade or -lock=false.

Run the normal reviewed plan for your existing working source with locking enabled and verify acquisition/release. For the full review package, OPEN_ITEMS.md and the enable_baseline_plan guard also apply. Backend locking changes do not require terraform apply; any infrastructure changes in a plan require separate review.

## After successful verification

Confirm every runner uses S3 locking. Remove DynamoDB IAM permissions and delete the old table only if it is not used by other states/projects. No automatic table deletion is included.

The lock is stored at terraform-aws-eks-v135.tfstate.tflock and is removed after a successful operation. Preserve state-object recovery versions. Do not manually delete a lock while a run is active.

Documentation: https://developer.hashicorp.com/terraform/language/backend/s3

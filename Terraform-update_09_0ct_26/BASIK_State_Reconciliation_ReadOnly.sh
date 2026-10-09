#!/usr/bin/env bash
# Read-only collection from the backend configured in the old Terraform archive.
# No imports, state push, Terraform apply, or resource mutations.
set -u
set -o pipefail
export AWS_PAGER=""
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'
REGION="ap-south-1"
BUCKET="basik-eks-state-bucket"
KEY="terraform-aws-eks-v135.tfstate"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
REPORT_DIR="$PWD/basik-state-reconciliation-$STAMP"
PRIVATE_DIR="$PWD/basik-private-state-backup-$STAMP"
mkdir -p "$REPORT_DIR" "$PRIVATE_DIR"
ACCOUNT="$(aws sts get-caller-identity --query Account --output text | tr -d '\r')" || exit 1
[ "$ACCOUNT" = "441718104055" ] || { echo "STOP: Wrong account $ACCOUNT"; exit 1; }
printf 'file\tstatus\n' > "$REPORT_DIR/collection-status.tsv"
collect() {
  local name="$1"; shift
  if "$@" > "$REPORT_DIR/$name.json" 2> "$REPORT_DIR/$name.error.txt" &&
     jq -e 'type == "object" or type == "array"' < "$REPORT_DIR/$name.json" >/dev/null 2>&1; then
    printf '%s\tOK\n' "$name" >> "$REPORT_DIR/collection-status.tsv"
    return 0
  fi
  printf '%s\tFAILED\n' "$name" >> "$REPORT_DIR/collection-status.tsv"
  echo "Read failed: $name"
  return 1
}
# Preserve raw state locally only. Never include this directory in the upload.
STATE_OUTPUT="$PRIVATE_DIR/current.private.tfstate"
# aws.exe needs a Windows filename because path conversion is disabled.
if command -v cygpath >/dev/null 2>&1; then
  STATE_OUTPUT="$(cygpath -w "$STATE_OUTPUT")"
fi
if aws s3api get-object --region "$REGION" --bucket "$BUCKET" --key "$KEY" \
  "$STATE_OUTPUT" > "$REPORT_DIR/state-object-metadata.json" \
  2> "$REPORT_DIR/state-read.error.txt"; then
  chmod 600 "$PRIVATE_DIR/current.private.tfstate" 2>/dev/null || true
  if jq '{terraform_version,serial,lineage,
    resources:[.resources[] | {module,mode,type,name,provider,
      instances:[.instances[] | {index_key,deposed,
        id:.attributes.id,name:.attributes.name,arn:.attributes.arn,
        cluster_name:.attributes.cluster_name,
        key_id:.attributes.key_id,target_key_id:.attributes.target_key_id,
        node_group_name:.attributes.node_group_name,
        instance_types:.attributes.instance_types,
        scaling_config:.attributes.scaling_config,
        launch_template:.attributes.launch_template,
        subnet_ids:.attributes.subnet_ids,
        encryption_config:(if .attributes.encryption_config then .attributes.encryption_config else null end),
        identity:(if .attributes.identity then .attributes.identity else null end),
        created_at:.attributes.created_at,
        policy_arn:.attributes.policy_arn
      }]}]}' < "$PRIVATE_DIR/current.private.tfstate" > "$REPORT_DIR/state-inventory.json"; then
    printf 'state-inventory\tOK\n' >> "$REPORT_DIR/collection-status.tsv"
  else
    printf 'state-inventory\tFAILED\n' >> "$REPORT_DIR/collection-status.tsv"
  fi
else
  printf 'state-read\tFAILED\n' >> "$REPORT_DIR/collection-status.tsv"
  echo "Could not read the backend object. Its error is included in the report."
fi
collect backend-versioning aws s3api get-bucket-versioning --bucket "$BUCKET" --output json || true
collect backend-encryption aws s3api get-bucket-encryption --bucket "$BUCKET" --output json || true
collect cluster aws eks describe-cluster --region "$REGION" --name basik-eks-cluster-v135 --output json || true
for LT in lt-057726ade3539b45a lt-0fb530dc964c9d730 lt-078aef1100c5a5d73; do
  collect "launch-template-$LT" aws ec2 describe-launch-template-versions --region "$REGION" \
    --launch-template-id "$LT" \
    --query 'LaunchTemplateVersions[].{ID:LaunchTemplateId,Name:LaunchTemplateName,Version:VersionNumber,Default:DefaultVersion,Data:{InstanceType:LaunchTemplateData.InstanceType,ImageId:LaunchTemplateData.ImageId,BlockDeviceMappings:LaunchTemplateData.BlockDeviceMappings,MetadataOptions:LaunchTemplateData.MetadataOptions,SecurityGroupIds:LaunchTemplateData.SecurityGroupIds,IamInstanceProfile:LaunchTemplateData.IamInstanceProfile,NetworkInterfaces:LaunchTemplateData.NetworkInterfaces,EbsOptimized:LaunchTemplateData.EbsOptimized,Monitoring:LaunchTemplateData.Monitoring,TagSpecifications:LaunchTemplateData.TagSpecifications}}' \
    --output json || true
done
collect kms-aliases aws kms list-aliases --region "$REGION" --key-id 793ea5bf-4924-4fbe-ba84-86030a29b490 --output json || true
collect karpenter-policies aws iam list-attached-role-policies \
  --role-name basik-eks-cluster-v135-karpenter-controller --output json || true
if jq -e '.AttachedPolicies' < "$REPORT_DIR/karpenter-policies.json" >/dev/null 2>&1; then
  while IFS= read -r ARN; do
    ARN="${ARN//$'\r'/}"; NAME="${ARN##*/}"
    if collect "policy-$NAME" aws iam get-policy --policy-arn "$ARN" --output json; then
      VERSION="$(jq -r '.Policy.DefaultVersionId' < "$REPORT_DIR/policy-$NAME.json" | tr -d '\r')"
      collect "policy-document-$NAME" aws iam get-policy-version --policy-arn "$ARN" \
        --version-id "$VERSION" --output json || true
    fi
  done < <(jq -r '.AttachedPolicies[].PolicyArn | select(startswith("arn:aws:iam::441718104055:policy/"))' < "$REPORT_DIR/karpenter-policies.json")
fi
# Only chart metadata from Helm release bodies is exported; no values or manifests.
for RELEASE in karpenter aws-load-balancer-controller; do
  SECRET="$(kubectl --context basik-blue -n kube-system get secrets -l "owner=helm,name=$RELEASE,status=deployed" -o json |
    jq -r '[.items[]] | sort_by(.metadata.labels.version|tonumber) | last | .metadata.name // empty' | tr -d '\r')"
  if [ -n "$SECRET" ] && kubectl --context basik-blue -n kube-system get secret "$SECRET" -o jsonpath='{.data.release}' |
    base64 -d | base64 -d | gzip -dc |
    jq '{name,namespace,revision:.version,chart:.chart.metadata.name,chartVersion:.chart.metadata.version,appVersion:.chart.metadata.appVersion}' \
    > "$REPORT_DIR/helm-chart-$RELEASE.json"; then
    printf 'helm-chart-%s\tOK\n' "$RELEASE" >> "$REPORT_DIR/collection-status.tsv"
  else
    printf 'helm-chart-%s\tFAILED\n' "$RELEASE" >> "$REPORT_DIR/collection-status.tsv"
  fi
done
tar -czf "${REPORT_DIR}.tar.gz" -C "$(dirname "$REPORT_DIR")" "$(basename "$REPORT_DIR")" || exit 1
printf '\nUpload ONLY this archive:\n%s\n' "${REPORT_DIR}.tar.gz"
printf '\nRaw state remains local in: %s\nDo not upload the private-state directory or raw .tfstate file.\n' "$PRIVATE_DIR"

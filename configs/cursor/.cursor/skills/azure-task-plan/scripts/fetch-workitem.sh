#!/usr/bin/env bash
# Fetch an Azure DevOps work item as JSON.
# Requires AZURE_DEVOPS_EXT_PAT in the environment.
set -euo pipefail

WI_ID="${1:?Usage: fetch-workitem.sh WORK_ITEM_ID [expand]}"
EXPAND="${2:-relations}"
ORG="${AZURE_DEVOPS_ORG:-https://dev.azure.com/bwkm}"
PROJECT="${AZURE_DEVOPS_PROJECT:-Gow Sign}"

if [[ -z "${AZURE_DEVOPS_EXT_PAT:-}" ]]; then
  echo "ERROR: AZURE_DEVOPS_EXT_PAT is not set." >&2
  echo "Export your Azure DevOps PAT before running this script." >&2
  exit 1
fi

if command -v az >/dev/null 2>&1; then
  for ORG_URL in "$ORG" "https://dev.azure.com/bwkm" "https://bwkm.visualstudio.com"; do
    if az boards work-item show \
      --id "$WI_ID" \
      --org "$ORG_URL" \
      --expand "$EXPAND" \
      -o json 2>/dev/null; then
      exit 0
    fi
  done
fi

ENCODED_PROJECT="${PROJECT// /%20}"
curl -sf -u ":${AZURE_DEVOPS_EXT_PAT}" \
  "${ORG}/${ENCODED_PROJECT}/_apis/wit/workitems/${WI_ID}?\$expand=${EXPAND}&api-version=7.0"

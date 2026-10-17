#!/bin/bash
# Prints deploy-policy.json with <ACCOUNT_ID> substituted for the account ID
# of whichever identity the AWS CLI is currently authenticated as. Nothing is
# written to disk - the account ID is resolved live, never stored, so
# deploy-policy.json itself can stay a placeholder and be committed as-is.
#
# Usage: cloudformation/render-deploy-policy.sh > /tmp/finance-tracker-deploy-policy.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

sed "s/<ACCOUNT_ID>/$ACCOUNT_ID/g" "$SCRIPT_DIR/deploy-policy.json"

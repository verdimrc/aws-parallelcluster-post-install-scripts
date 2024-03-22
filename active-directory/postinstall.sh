#!/bin/bash

# This is the active-directory.head.post.sh from
# https://docs.aws.amazon.com/parallelcluster/latest/ug/tutorials_05_multi-user-ad.html

set -e

CERTIFICATE_SECRET_ARN="$1"
CERTIFICATE_PATH="$2"

[[ -z $CERTIFICATE_SECRET_ARN ]] && echo "[ERROR] Missing CERTIFICATE_SECRET_ARN" && exit 1
[[ -z $CERTIFICATE_PATH ]] && echo "[ERROR] Missing CERTIFICATE_PATH" && exit 1

source /etc/parallelcluster/cfnconfig
REGION="${cfn_region:?}"

mkdir -p $(dirname $CERTIFICATE_PATH)
aws secretsmanager get-secret-value --region $REGION --secret-id $CERTIFICATE_SECRET_ARN --query SecretString --output text > $CERTIFICATE_PATH

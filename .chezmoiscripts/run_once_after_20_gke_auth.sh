#! /usr/bin/env bash
set -euo pipefail

# check if gcloud is installed
if ! command -v gcloud >/dev/null 2>&1; then
    echo "gcloud not found in PATH; skipping gke auth plugin install (safe no-op)."
    exit 1 
fi
gcloud components install gke-gcloud-auth-plugin --quiet
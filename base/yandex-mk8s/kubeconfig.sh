#!/bin/bash
set -euo pipefail

: "${KUBECONFIG_DIR:?}"
: "${K3S_HOST:?}"
: "${K3S_SSH_KEY:?}"
: "${CLUSTER_ID:?}"
: "${CLOUD_ID:?}"
: "${FOLDER_ID:?}"

mkdir -p "$KUBECONFIG_DIR"

ssh_k3s() {
  ssh -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 \
    -i "$K3S_SSH_KEY" "ubuntu@${K3S_HOST}" "$@"
}

deadline=$((SECONDS + 900))
until ssh_k3s 'sudo test -s /etc/rancher/k3s/k3s.yaml'; do
  if ((SECONDS >= deadline)); then
    echo "k3s kubeconfig did not appear within 900s" >&2
    exit 1
  fi
  sleep 10
done

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
ssh_k3s 'sudo cat /etc/rancher/k3s/k3s.yaml' \
  | sed "s#https://127.0.0.1:6443#https://${K3S_HOST}:6443#" \
  > "$tmp"
install -m 600 "$tmp" "${KUBECONFIG_DIR}/k3s.kubeconfig"

yc managed-kubernetes cluster get-credentials \
  --id "$CLUSTER_ID" \
  --external \
  --kubeconfig "${KUBECONFIG_DIR}/mk8s.kubeconfig" \
  --force \
  --cloud-id "$CLOUD_ID" \
  --folder-id "$FOLDER_ID"
chmod 600 "${KUBECONFIG_DIR}/mk8s.kubeconfig"

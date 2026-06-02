#!/bin/sh
set -eu

if [ -z "${NOMAD_ADDR:-}" ]; then
  echo "NOMAD_ADDR must be set." >&2
  exit 1
fi

if [ -z "${NOMAD_TOKEN:-}" ]; then
  echo "NOMAD_TOKEN must be set." >&2
  exit 1
fi

export TF_IN_AUTOMATION="${TF_IN_AUTOMATION:-1}"
export CHECKPOINT_DISABLE="${CHECKPOINT_DISABLE:-1}"
export TF_VAR_bootstrap_token_secret_id="${TF_VAR_bootstrap_token_secret_id:-$NOMAD_TOKEN}"

cd /workspace

if [ "${BOOTSTRAP_ON_START:-1}" = "1" ]; then
  terraform -chdir=bootstrap init -input=false
  terraform -chdir=bootstrap apply -input=false -auto-approve
fi

if [ "$#" -eq 0 ]; then
  exec sh
fi

exec "$@"

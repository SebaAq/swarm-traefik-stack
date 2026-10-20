#!/usr/bin/env bash
# Despliega el stack en Docker Swarm usando las variables de .env
set -euo pipefail
cd "$(dirname "$0")"

[[ -f .env ]] || { echo "Falta .env: copiá .env.example y completalo." >&2; exit 1; }
set -a
# shellcheck source=/dev/null
. ./.env
set +a

if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q active; then
  echo "Este nodo no está en un Swarm. Inicialo con: docker swarm init" >&2
  exit 1
fi

docker network inspect proxy >/dev/null 2>&1 || docker network create --driver overlay --attachable proxy
docker stack deploy --compose-file stack.yml --prune "${STACK_NAME:-core}"
echo "Listo. Mirá el estado con: docker stack services ${STACK_NAME:-core}"

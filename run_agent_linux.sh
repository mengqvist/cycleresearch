#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="cycleresearch-claude"
CONFIG_VOLUME="cycleresearch-claude-config"
MODE="${1:-run}"

echo "Building Docker image..."
docker build -t "$IMAGE_NAME" .

docker volume create "$CONFIG_VOLUME" >/dev/null

run_container() {
  docker run -it --rm \
    --user "$(id -u):$(id -g)" \
    --init \
    -e CLAUDE_CONFIG_DIR=/home/claude/.claude \
    -e UV_LINK_MODE=copy \
    -v "$PWD":/workspace \
    -v "$CONFIG_VOLUME":/home/claude/.claude \
    -w /workspace \
    "$IMAGE_NAME" \
    bash -lc "$1"
}

case "$MODE" in
  login)
    echo "Starting Claude login..."
    run_container 'exec claude'
    ;;

  run)
    echo "Starting autonomous session..."
    run_container 'uv sync && exec claude --model opus --effort max --dangerously-skip-permissions'
    ;;

  shell)
    run_container 'exec bash'
    ;;

  *)
    echo "Usage: ./run_agent.sh [login|run|shell]"
    exit 1
    ;;
esac
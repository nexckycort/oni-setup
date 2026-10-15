ensure_app docker docker
if ! docker buildx version >/dev/null 2>&1; then packages docker-buildx; fi
if ! docker compose version >/dev/null 2>&1; then packages docker-compose; fi
ensure_community_app lazydocker lazydocker

# Nombres propios: no altera contenedores existentes ajenos a Oni.
start_database() {
  local name=$1
  shift
  if sudo docker container inspect "$name" >/dev/null 2>&1; then
    if [[ $(sudo docker inspect --format '{{.State.Running}}' "$name") != true ]]; then
      sudo docker start "$name" >/dev/null
    fi
  else
    sudo docker run -d --restart unless-stopped --name "$name" "$@"
  fi
}
while IFS= read -r database; do
  case "$database" in
    MySQL) start_database oni-mysql8 -p 127.0.0.1:3306:3306 \
      -v oni-mysql8:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=oni-local mysql:8.4 ;;
    Redis) start_database oni-redis -p 127.0.0.1:6379:6379 \
      -v oni-redis:/data redis:7 redis-server --appendonly yes ;;
    PostgreSQL) start_database oni-postgres16 -p 127.0.0.1:5432:5432 \
      -v oni-postgres16:/var/lib/postgresql/data -e POSTGRES_PASSWORD=oni-local postgres:16 ;;
  esac
done <<< "$DATABASES"

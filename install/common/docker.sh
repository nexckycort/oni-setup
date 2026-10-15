# Conserva daemon.json si ya existe; nunca pisa ajustes locales.
if ! sudo test -e /etc/docker/daemon.json; then
  sudo install -d -m 0755 /etc/docker
  sudo install -m 0644 "$ROOT/configs/docker-daemon.json" /etc/docker/daemon.json
fi
if ! systemctl is-enabled --quiet docker.service; then sudo systemctl enable docker.service; fi
if ! systemctl is-active --quiet docker.service; then sudo systemctl start docker.service; fi
if [[ $DOCKER_GROUP == true ]] && ! id -nG | tr ' ' '\n' | grep -Fxq docker; then
  sudo usermod -aG docker "$(id -un)"
fi

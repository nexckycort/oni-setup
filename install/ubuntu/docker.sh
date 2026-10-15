# Conserva el motor instalado y completa solo sus plugins faltantes.
if ! command -v docker >/dev/null 2>&1; then
  apt_vendor_repo docker https://download.docker.com/linux/ubuntu/gpg \
    https://download.docker.com/linux/ubuntu "$DISTRO_CODENAME" stable
  packages docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
elif ! docker buildx version >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  if package_installed docker-ce-cli; then
    apt_vendor_repo docker https://download.docker.com/linux/ubuntu/gpg \
      https://download.docker.com/linux/ubuntu "$DISTRO_CODENAME" stable
    if ! docker buildx version >/dev/null 2>&1; then packages docker-buildx-plugin; fi
    if ! docker compose version >/dev/null 2>&1; then packages docker-compose-plugin; fi
  elif package_installed docker.io; then
    if ! docker buildx version >/dev/null 2>&1; then packages docker-buildx; fi
    if ! docker compose version >/dev/null 2>&1; then packages docker-compose-v2; fi
  else
    echo 'Docker existente de origen desconocido: completa sus plugins Buildx/Compose antes de continuar.' >&2
    exit 1
  fi
fi
if ! command -v lazydocker >/dev/null 2>&1; then
  release_asset jesseduffield/lazydocker '^lazydocker_[0-9.]+_Linux_x86_64\.tar\.gz$' lazydocker
fi

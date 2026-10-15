#!/usr/bin/env bash
# Gestores y sudo simulados: no instala paquetes ni toca configuración del usuario.
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEST_DIR"' EXIT
source "$ROOT/install/common/helpers.sh"
fail() { printf 'FALLO: %s\n' "$*" >&2; exit 1; }

# Estas funciones sustituyen todos los comandos que modificarían el sistema.
pacman() {
  [[ $1 == -Q ]] || fail "consulta pacman inesperada: $*"
  grep -Fxq -- "$2" "$TEST_DIR/installed"
}
dpkg-query() {
  if grep -Fxq -- "${@: -1}" "$TEST_DIR/installed"; then
    printf 'install ok installed'
  else
    printf 'deinstall ok config-files'
    return 0
  fi
}
sudo() {
  printf '%s\n' "$*" >> "$TEST_DIR/calls"
  case "$*" in
    'pacman -Syu'|'apt-get update') ;;
    'pacman -S --needed '*|'apt-get install -y '*)
      shift 3
      printf '%s\n' "$@" >> "$TEST_DIR/installed"
      ;;
    *) fail "acción no simulada: $*" ;;
  esac
}

for family in arch ubuntu; do
  source "$ROOT/install/$family/packages.sh"
  ARCH_SYNCED=false
  APT_REFRESHED=false
  printf 'existing\n' > "$TEST_DIR/installed"
  : > "$TEST_DIR/calls"
  packages existing
  [[ ! -s $TEST_DIR/calls ]] || fail "$family modifica el sistema sin paquetes faltantes"

  packages existing missing
  if [[ $family == arch ]]; then
    printf 'pacman -Syu\npacman -S --needed missing\n' > "$TEST_DIR/expected"
  else
    printf 'apt-get update\napt-get install -y missing\n' > "$TEST_DIR/expected"
  fi
  cmp -s "$TEST_DIR/calls" "$TEST_DIR/expected" || fail "$family no instala solo lo faltante"
  : > "$TEST_DIR/calls"
  packages existing missing
  [[ ! -s $TEST_DIR/calls ]] || fail "$family reinstala al repetir"
  if [[ $family == arch ]]; then
    community_package existing
    [[ ! -s $TEST_DIR/calls ]] || fail 'AUR reinstala un paquete existente'
  fi
  printf 'OK: %s omite existentes, instala faltantes y permite repetir.\n' "$family"
done

packages() { fail "instalación inesperada: $*"; }
community_package() { fail "instalación AUR inesperada: $*"; }
apt_vendor_repo() { fail "repositorio inesperado: $*"; }
code() { :; }
google-chrome() { :; }
docker() { [[ $* == 'buildx version' || $* == 'compose version' ]]; }
lazydocker() { :; }
for family in arch ubuntu; do
  source "$ROOT/install/$family/desktop.sh"
  source "$ROOT/install/$family/docker.sh"
done
echo 'OK: VS Code, Chrome y Docker completos no se reinstalan ni añaden repositorios.'

packages() { printf '%s\n' "$*" >> "$TEST_DIR/plugins"; }
docker() { [[ $* == 'compose version' ]]; }
: > "$TEST_DIR/plugins"
source "$ROOT/install/arch/docker.sh"
[[ $(cat "$TEST_DIR/plugins") == docker-buildx ]] || fail 'Arch no completa solo Buildx'
: > "$TEST_DIR/plugins"
printf 'docker.io\n' >> "$TEST_DIR/installed"
source "$ROOT/install/ubuntu/docker.sh"
[[ $(cat "$TEST_DIR/plugins") == docker-buildx ]] || fail 'Ubuntu sustituye docker.io o reinstala Compose'
echo 'OK: Docker existente conserva el motor y completa solo el plugin faltante.'

mise() { :; }
pnpm() { :; }
curl() { fail 'descarga inesperada con mise y pnpm existentes'; }
ZSH_CONFIG_DIR=$TEST_DIR
source "$ROOT/install/common/runtimes.sh"
echo 'OK: mise y pnpm existentes no ejecutan descargas.'

printf 'original\n' > "$TEST_DIR/config"
printf 'nuevo\n' > "$TEST_DIR/source"
copy_if_missing "$TEST_DIR/source" "$TEST_DIR/config"
[[ $(cat "$TEST_DIR/config") == original ]] || fail 'sobrescribe configuración existente'
copy_if_missing "$TEST_DIR/source" "$TEST_DIR/new-config"
cmp -s "$TEST_DIR/source" "$TEST_DIR/new-config" || fail 'no crea configuración faltante'
append_once 'línea oni' "$TEST_DIR/config"
append_once 'línea oni' "$TEST_DIR/config"
[[ $(grep -Fxc 'línea oni' "$TEST_DIR/config") == 1 ]] || fail 'duplica líneas de configuración'
echo 'OK: conserva configuración existente y no duplica líneas.'

#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
export ROOT
if [[ ${1:-} != --apply || $# != 1 ]]; then
  printf 'Oni Setup para Ubuntu, Arch Linux y CachyOS. Sin argumentos no modifica el sistema.\n'
  printf 'Revisa README.md y los scripts; para instalar: bash install.sh --apply\n'
  exit 0
fi
[[ $EUID -ne 0 ]] || { echo 'Ejecuta como usuario normal con sudo, no como root.' >&2; exit 1; }
source "$ROOT/install/common/distro.sh"
detect_distro /etc/os-release
trap 'printf "Falló la instalación en %s:%s. Revisa el error antes de reintentar.\n" "${BASH_SOURCE[0]}" "$LINENO" >&2' ERR
source "$ROOT/install/common/helpers.sh"
source "$ROOT/install/$DISTRO_FAMILY/packages.sh"
source "$ROOT/install/$DISTRO_FAMILY/languages.sh"
printf 'Sistema detectado: %s; módulos: %s\n' "$DISTRO_ID" "$DISTRO_FAMILY"
ZSH_CONFIG_DIR=${ZDOTDIR:-$HOME}
mkdir -p -- "$ZSH_CONFIG_DIR"
if [[ -f $ZSH_CONFIG_DIR/.zshrc ]]; then
  cp -p -- "$ZSH_CONFIG_DIR/.zshrc" "$ZSH_CONFIG_DIR/.zshrc.oni-backup-$(date +%Y%m%d-%H%M%S)"
fi

source "$ROOT/install/$DISTRO_FAMILY/base.sh"
source "$ROOT/install/common/choices.sh"
source "$ROOT/install/common/runtimes.sh"
source "$ROOT/install/$DISTRO_FAMILY/docker.sh"
source "$ROOT/install/common/docker.sh"
source "$ROOT/install/$DISTRO_FAMILY/desktop.sh"
source "$ROOT/install/common/shell.sh"
source "$ROOT/install/common/languages.sh"
source "$ROOT/install/common/storage.sh"
printf '\nConfiguración terminada. Cierra sesión y vuelve a entrar para aplicar Zsh y el grupo docker.\n'

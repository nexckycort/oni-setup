# Sourced by install.sh, never run independently.
package_installed() { pacman -Q "$1" >/dev/null 2>&1; }

arch_sync() {
  if [[ ${ARCH_SYNCED:-false} != true ]]; then
    echo 'Arch requiere una actualización completa antes de instalar paquetes nuevos.'
    sudo pacman -Syu
    ARCH_SYNCED=true
  fi
}

packages() {
  local package
  local missing=()
  for package in "$@"; do
    if package_installed "$package"; then
      printf '✔ %s ya está instalado; se omite.\n' "$package"
    else
      missing+=("$package")
    fi
  done
  if (( ${#missing[@]} )); then
    arch_sync
    sudo pacman -S --needed "${missing[@]}"
  fi
}

community_package() {
  local package=$1
  if package_installed "$package"; then
    printf '✔ %s ya está instalado; se omite.\n' "$package"
    return 0
  fi
  arch_sync
  if pacman -Si "$package" >/dev/null 2>&1; then
    packages "$package"
  else
    if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
      if pacman -Si paru >/dev/null 2>&1; then
        packages paru
      else
        # Arch puro no incluye paru en sus repositorios. Construir como usuario.
        (
          build_dir=$(mktemp -d)
          trap 'rm -rf -- "$build_dir"' EXIT
          git clone https://aur.archlinux.org/paru.git "$build_dir/paru"
          cd -- "$build_dir/paru"
          printf 'Revisa PKGBUILD de paru antes de compilar:\n'
          cat PKGBUILD
          gum confirm '¿Compilar e instalar paru desde este PKGBUILD?'
          makepkg -si
        )
      fi
    fi
    # Run as the user; keep PKGBUILD review and package-manager prompts enabled.
    if command -v paru >/dev/null 2>&1; then
      paru -S --needed "$package"
    else
      yay -S --needed "$package"
    fi
  fi
}

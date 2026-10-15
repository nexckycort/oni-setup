package_installed() {
  [[ $(dpkg-query -W -f='${Status}' "$1" 2>/dev/null) == 'install ok installed' ]]
}

apt_refresh() {
  if [[ ${APT_REFRESHED:-false} != true ]]; then
    sudo apt-get update
    APT_REFRESHED=true
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
    apt_refresh
    sudo apt-get install -y "${missing[@]}"
  fi
}

# Repositorios oficiales de los proveedores, sin duplicarlos al reintentar.
apt_vendor_repo() {
  local name=$1 key_url=$2 repository=$3 suite=$4 component=$5
  if [[ -s /etc/apt/keyrings/oni-$name.gpg && -s /etc/apt/sources.list.d/oni-$name.list ]]; then
    apt_refresh
    return 0
  fi
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL "$key_url" | gpg --dearmor | sudo tee "/etc/apt/keyrings/oni-$name.gpg" >/dev/null
  sudo chmod 0644 "/etc/apt/keyrings/oni-$name.gpg"
  printf 'deb [arch=amd64 signed-by=/etc/apt/keyrings/oni-%s.gpg] %s %s %s\n' \
    "$name" "$repository" "$suite" "$component" | sudo tee "/etc/apt/sources.list.d/oni-$name.list" >/dev/null
  sudo apt-get update
  APT_REFRESHED=true
}

# Descarga un asset publicado por el proyecto y valida su digest de GitHub.
# Cada llamada ocurre en un subshell para limpiar temporales incluso al fallar.
release_asset() (
  set -Eeuo pipefail
  local repository=$1 pattern=$2 action=$3
  local temp_dir metadata asset url digest filename
  temp_dir=$(mktemp -d)
  trap 'rm -rf -- "$temp_dir"' EXIT
  metadata=$(curl -fsSL "https://api.github.com/repos/$repository/releases/latest")
  asset=$(jq -cer --arg pattern "$pattern" '[.assets[] | select(.name | test($pattern))] | if length == 1 then .[0] else error("Asset ausente o ambiguo") end' <<< "$metadata")
  url=$(jq -r '.browser_download_url' <<< "$asset")
  digest=$(jq -r '.digest // ""' <<< "$asset")
  filename=$(jq -r '.name' <<< "$asset")
  [[ $digest =~ ^sha256:[a-fA-F0-9]{64}$ ]] || { echo 'El release no publica un digest SHA256; se cancela.' >&2; exit 1; }
  curl -fL --retry 3 "$url" -o "$temp_dir/$filename"
  printf '%s  %s\n' "${digest#sha256:}" "$temp_dir/$filename" | sha256sum --check --status
  case "$action" in
    deb) sudo apt-get install -y "$temp_dir/$filename" ;;
    lazydocker)
      tar -xzf "$temp_dir/$filename" -C "$temp_dir" lazydocker
      sudo install -m 0755 "$temp_dir/lazydocker" /usr/local/bin/lazydocker
      ;;
    *) echo 'Tipo de asset desconocido.' >&2; exit 1 ;;
  esac
)

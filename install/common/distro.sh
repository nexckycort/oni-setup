# Solo define la detección; no instala ni modifica archivos.
detect_distro() {
  local release_file=$1
  local ID='' ID_LIKE='' VERSION_ID='' VERSION_CODENAME=''
  [[ -r $release_file ]] || { echo 'No se pudo leer os-release.' >&2; return 1; }
  source "$release_file"
  DISTRO_ID=$ID
  DISTRO_VERSION=$VERSION_ID
  DISTRO_CODENAME=$VERSION_CODENAME
  case "$ID" in
    ubuntu)
      case "$VERSION_ID" in
        24.04|26.04|26.10) DISTRO_FAMILY=ubuntu ;;
        *) printf 'Versión de Ubuntu no admitida: %s\n' "$VERSION_ID" >&2; return 1 ;;
      esac
      ;;
    arch|cachyos) DISTRO_FAMILY=arch ;;
    *)
      printf 'Distribución no admitida: %s (ID_LIKE=%s). No se aplicarán cambios.\n' "$ID" "$ID_LIKE" >&2
      return 1
      ;;
  esac
  [[ $(uname -m) == x86_64 ]] || { echo 'Por ahora solo se admite x86_64.' >&2; return 1; }
}

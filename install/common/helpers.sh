ensure_app() {
  local package=$1 executable=$2
  if command -v "$executable" >/dev/null 2>&1; then
    printf '✔ %s ya está disponible; se omite.\n' "$executable"
  else
    packages "$package"
  fi
}

ensure_community_app() {
  local package=$1 executable=$2
  if command -v "$executable" >/dev/null 2>&1; then
    printf '✔ %s ya está disponible; se omite.\n' "$executable"
  else
    community_package "$package"
  fi
}

git_default() {
  if ! git config --global --get "$1" >/dev/null; then git config --global "$1" "$2"; fi
}

copy_if_missing() {
  local source_file=$1 target=$2
  if [[ ! -e $target && ! -L $target ]]; then
    mkdir -p -- "$(dirname -- "$target")"
    cp -- "$source_file" "$target"
  fi
}

append_once() {
  local line=$1 target=$2
  touch -- "$target"
  if ! grep -Fqx -- "$line" "$target"; then printf '\n%s\n' "$line" >> "$target"; fi
}

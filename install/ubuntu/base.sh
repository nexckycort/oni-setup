packages build-essential ca-certificates
for app in curl git unzip zsh jq btop; do ensure_app "$app" "$app"; done
ensure_app gnupg gpg
if ! command -v gum >/dev/null 2>&1; then
  apt_vendor_repo charm https://repo.charm.sh/apt/gpg.key https://repo.charm.sh/apt/ '*' '*'
  packages gum
fi
if ! command -v fastfetch >/dev/null 2>&1; then
  if apt-cache show fastfetch >/dev/null 2>&1; then
    packages fastfetch
  else
    release_asset fastfetch-cli/fastfetch '^fastfetch-linux-amd64\.deb$' deb
  fi
fi

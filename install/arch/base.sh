packages base-devel ca-certificates
for app in curl git unzip zsh gum btop fastfetch jq; do ensure_app "$app" "$app"; done

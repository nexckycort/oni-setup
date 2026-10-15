# Detecta también instalaciones existentes que aún no estén en PATH.
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
export PATH="$HOME/.local/bin:$PNPM_HOME:$PATH"
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi
if ! command -v pnpm >/dev/null 2>&1; then
  # Endpoint oficial completo; get.pnpm.io sin /install.sh no es el instalador documentado.
  curl -fsSL https://get.pnpm.io/install.sh | ENV="$ZSH_CONFIG_DIR/.zshrc" SHELL="$(command -v zsh)" sh -
fi
command -v mise >/dev/null
command -v pnpm >/dev/null
eval "$(mise activate bash)"

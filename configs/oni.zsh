# Carga Oh My Zsh si la configuración existente todavía no lo cargó.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -z ${ZSH_VERSION:-} ]]; then return; fi
if (( ! $+functions[omz] )) && [[ -f $ZSH/oh-my-zsh.sh ]]; then
  ZSH_THEME="${ZSH_THEME:-robbyrussell}"
  source "$ZSH/oh-my-zsh.sh"
fi
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
typeset -U path PATH
path=("$HOME/.local/bin" "$PNPM_HOME" $path)
if (( $+commands[mise] )); then eval "$(mise activate zsh)"; fi
alias lzd=lazydocker
alias pn=pnpm

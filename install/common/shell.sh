ZSH_CONFIG_DIR=${ZDOTDIR:-$HOME}
mkdir -p -- "$ZSH_CONFIG_DIR"
if [[ ! -d $HOME/.oh-my-zsh ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
mkdir -p -- "${XDG_CONFIG_HOME:-$HOME/.config}/oni-setup"
copy_if_missing "$ROOT/configs/oni.zsh" "${XDG_CONFIG_HOME:-$HOME/.config}/oni-setup/oni.zsh"
append_once 'source "${XDG_CONFIG_HOME:-$HOME/.config}/oni-setup/oni.zsh"' "$ZSH_CONFIG_DIR/.zshrc"
if [[ $CHANGE_SHELL == true ]] && [[ $(getent passwd "$(id -un)" | cut -d: -f7) != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

git_default pull.rebase true
git_default init.defaultBranch main
if [[ -n ${GIT_NAME//[[:space:]]/} ]]; then git config --global user.name "$GIT_NAME"; fi
if [[ -n ${GIT_EMAIL//[[:space:]]/} ]]; then git config --global user.email "$GIT_EMAIL"; fi
if [[ $GIT_SSH == true ]]; then git config --global url.'ssh://git@github.com/'.insteadOf 'https://github.com/'; fi

CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
copy_if_missing "$ROOT/configs/fastfetch.jsonc" "$CONFIG_HOME/fastfetch/config.jsonc"

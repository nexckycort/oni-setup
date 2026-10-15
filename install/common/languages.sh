# Lee líneas completas: Ruby on Rails es una sola opción.
while IFS= read -r language; do
  case "$language" in
    'Ruby on Rails')
      if ! command -v ruby >/dev/null; then
        language_dependencies ruby
        mise use --global ruby@latest
      fi
      if ! mise exec -- gem list -i rails >/dev/null; then mise exec -- gem install rails --no-document; fi
      ;;
    Node.js) if ! command -v node >/dev/null; then mise use --global node@lts; fi ;;
    Go) if ! command -v go >/dev/null; then mise use --global go@latest; fi ;;
    PHP)
      install_php
      ;;
    Python)
      if ! command -v python3 >/dev/null; then
        language_dependencies python
        mise use --global python@latest
      fi
      ;;
    Elixir)
      if ! command -v erl >/dev/null; then
        language_dependencies elixir
        mise use --global erlang@latest
      fi
      if ! command -v elixir >/dev/null; then mise use --global elixir@latest; fi
      if [[ ! -d ${MIX_HOME:-$HOME/.mix}/archives ]] || ! compgen -G "${MIX_HOME:-$HOME/.mix}/archives/hex-*" >/dev/null; then
        mise exec -- mix local.hex --force
      fi
      ;;
    Rust) if ! command -v rustc >/dev/null; then mise use --global rust@stable; fi ;;
    Java) if ! command -v java >/dev/null; then mise use --global java@latest; fi ;;
  esac
done <<< "$LANGUAGES"

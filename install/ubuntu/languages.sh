language_dependencies() {
  case "$1" in
    ruby) packages libssl-dev libyaml-dev libffi-dev libreadline-dev zlib1g-dev libgmp-dev ;;
    python) packages libssl-dev zlib1g-dev liblzma-dev tk-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev ;;
    elixir) packages libssl-dev libncurses-dev libxslt1-dev unixodbc-dev libwxgtk3.2-dev ;;
  esac
}

install_php() {
  # Versión mantenida por Ubuntu, sin fijar un PPA o una versión de PHP.
  packages php-cli php-curl php-apcu php-intl php-mbstring php-opcache \
    php-pgsql php-mysql php-sqlite3 php-redis php-xml php-zip composer
}

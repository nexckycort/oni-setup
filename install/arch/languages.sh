language_dependencies() {
  case "$1" in
    ruby) packages openssl libyaml libffi readline zlib gmp ;;
    python) packages openssl zlib xz tk libffi bzip2 readline sqlite ;;
    elixir) packages openssl ncurses libxslt unixodbc wxwidgets-gtk3 ;;
  esac
}

install_php() {
      packages php php-apcu php-pgsql php-sqlite php-redis composer
      # Extensiones compartidas de Arch se activan mediante conf.d.
      sudo install -d -m 0755 /etc/php/conf.d
      for extension in curl intl mbstring pdo_mysql pdo_pgsql pdo_sqlite mysqli pgsql sqlite3 zip apcu redis; do
        if [[ -f /usr/lib/php/modules/$extension.so ]] && ! php -m | grep -Fxiq -- "$extension"; then
          printf 'extension=%s\n' "$extension" | sudo tee "/etc/php/conf.d/oni-$extension.ini" >/dev/null
        fi
      done
}

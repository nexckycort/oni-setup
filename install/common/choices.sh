LANGUAGES=$(gum choose --no-limit --height 10 --header 'Lenguajes (espacio para seleccionar, Enter para continuar)' \
  'Ruby on Rails' 'Node.js' 'Go' 'PHP' 'Python' 'Elixir' 'Rust' 'Java')
DATABASES=$(gum choose --no-limit --selected PostgreSQL --height 5 \
  --header 'Bases de datos locales en Docker' MySQL Redis PostgreSQL)
GIT_NAME=$(gum input --header 'Nombre para Git (vacío conserva el actual)' \
  --value "$(git config --global user.name || true)")
GIT_EMAIL=$(gum input --header 'Correo para Git (vacío conserva el actual)' \
  --value "$(git config --global user.email || true)")
GIT_SSH=false
if gum confirm '¿Reescribir HTTPS de GitHub a SSH? Requiere una clave registrada.'; then GIT_SSH=true; fi
CHANGE_SHELL=false
if gum confirm '¿Usar Zsh como shell por defecto?'; then CHANGE_SHELL=true; fi
DOCKER_GROUP=false
if gum confirm '¿Añadir tu usuario al grupo docker? Este grupo tiene privilegios equivalentes a root.'; then DOCKER_GROUP=true; fi

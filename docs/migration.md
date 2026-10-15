# Unificación de oni-setup

Origen: [nexckycort/oni-setup](https://github.com/nexckycort/oni-setup), commit
`66a0a2296164ed62ef849a50c8c3e9ca16f4c446`, revisado el 15 de octubre de 2026.
Se revisaron todos los scripts, ambas configuraciones y el tema.

| Original | Versión CachyOS |
| --- | --- |
| `boot.sh` | Entrada remota de un comando: descarga el repositorio como archivo en una carpeta temporal, ejecuta `install.sh --apply` y limpia la descarga al terminar. Sin clonar ni cambiar Git. |
| `install.sh` | Bash estricto, comprobación de CachyOS/usuario y módulos con orden explícito. |
| `install/terminal.sh` | Solo paquetes faltantes: Arch usa pacman y base-devel; Ubuntu usa apt y build-essential, sin upgrade general. |
| `required/app-gum.sh` | Gum desde pacman o el repositorio oficial de Charm para Ubuntu. |
| `first-run-choices.sh` | Ocho lenguajes y tres bases de datos; PostgreSQL seleccionado por defecto. Sin detección automática de opciones marcadas; se conserva cada lenguaje disponible al instalar. |
| `identification.sh` | Nombre/correo actuales de Git como valores iniciales; vacío conserva el valor existente. |
| `app-btop.sh` | Paquete `btop` sin configuración ni tema personalizado, por preferencia del usuario. |
| `app-fastfetch.sh` | Configuración original; pacman en Arch, apt o release oficial con digest en Ubuntu. |
| `app-lazydocker.sh` | Paquete en Arch; release oficial con digest SHA256 en Ubuntu. |
| `docker.sh` | Paquetes de Arch o repositorio oficial de Docker para Ubuntu; configuración y servicio compartidos. Grupo docker opcional. |
| `mise.sh` | `curl -fsSL https://mise.run \| sh` si falta mise; sin repositorio Debian. |
| `pnpm.sh` | Instalador oficial `https://get.pnpm.io/install.sh`, detección en PATH y PNPM_HOME. |
| `oh-my-zsh.sh` | Conserva instalación/configuración existentes; evita cambio de shell automático del instalador remoto. Cambio a Zsh opcional. |
| `set-git.sh` | Rebase y main como valores predeterminados sin sobrescribir ajustes existentes; identidad interactiva y HTTPS a SSH opcional. |
| `zshrc-aliases.sh` | `lzd`, `pn` y PATH de pnpm en `configs/oni.zsh`, sin duplicar líneas de carga. |
| `select-dev-language.sh` | Selección por líneas completas: corrige `Ruby on Rails`, que antes se separaba por espacios. Mise para runtimes; apt o pacman para PHP/Composer. |
| `select-dev-storage.sh` | Mismas imágenes base; nombres Oni, volúmenes persistentes, loopback y contraseñas locales explícitas para SQL. Reutiliza contenedores existentes. |
| `install/desktop/.gitkeep` | Sustituido por módulo real para VS Code y Chrome. El original no contiene instaladores de escritorio. |
| `configs/fastfetch.jsonc` | Copiado íntegramente. La configuración de btop y el tema Tokyo Night se omiten por preferencia del usuario. |
| `README.md` | Instrucciones, efectos, límites y estado de validación para Ubuntu, Arch y CachyOS. |

El original invoca `install/desktop.sh` cuando detecta GNOME, pero ese archivo
no existe. También carga todos los módulos del terminal por orden alfabético;
ahora las dependencias se ejecutan antes de sus consumidores. Se eliminan los
cambios temporales de bloqueo/suspensión de GNOME.

## Separación por distribución

`common/distro.sh` decide la familia a partir de `ID` en `/etc/os-release`.
Acepta Ubuntu 24.04/26.04/26.10, Arch y CachyOS en x86_64; informa de `ID_LIKE`
pero rechaza otras derivadas antes de ejecutar sudo o escribir configuración.

`common/` contiene elecciones, mise/pnpm, Git/Zsh, configuración de Docker,
selección de lenguajes y bases de datos. `ubuntu/` y `arch/` contienen gestores
de paquetes, instalación base, Docker, escritorio y dependencias de lenguajes.
No hay comandos apt en Arch ni pacman en Ubuntu.

Ubuntu conserva apt y Docker CE con su repositorio oficial. VS Code y Chrome
usan repositorios de sus proveedores. Se elimina el PPA de PHP: se utiliza la
versión de Ubuntu con extensiones y Composer. Fastfetch y lazydocker pueden
usar releases oficiales con verificación del digest SHA256 publicado por GitHub.

Arch usa pacman y AUR. Paru deja de depender exclusivamente de CachyOS: se
reutiliza paru/yay, se instala paru de repositorios cuando exista o se ofrece
construirlo desde AUR con revisión de PKGBUILD y como usuario normal.

PHP en Arch usa `php`, `php-apcu`, `php-pgsql`, `php-sqlite`, `php-redis` y
`composer`; se activan las extensiones compartidas que falten en conf.d. En los
metadatos consultados, `php` incluye/provee `php-intl`. XML y OPcache siguen el
empaquetado de la distribución. En Ubuntu se usan los paquetes `php-*` de apt.
Se usa Docker como servicio del sistema, sin configurar un daemon rootless.

La carpeta local se renombró de `oni-setup-cachyos` a `oni-setup`, conservando
los cambios preparados y recuperando el historial Git del proyecto original.
La configuración compartida de Zsh se instala en `$XDG_CONFIG_HOME/oni-setup/`.
La versión anterior no se había ejecutado, por lo que no hay migración de
configuración instalada. La unificación conserva el historial del repositorio original.

El instalador consulta primero los paquetes locales y detecta aplicaciones en
PATH. Omite los existentes, conserva el motor de Docker y completa plugins que
falten; no sobrescribe configuraciones de Oni ya creadas. Ubuntu no ejecuta un
upgrade general; Arch/CachyOS hace una actualización completa una vez, solo si
necesita instalar paquetes. Las pruebas en Bash simulan gestores y sudo para
comprobar estas decisiones sin ejecutar instalaciones reales.

## Referencias consultadas

- [Instalación de mise](https://mise.jdx.dev/installing-mise.html).
- [Instalación de pnpm](https://pnpm.io/installation).
- [Docker en Arch](https://wiki.archlinux.org/title/Docker).
- [Paquete Docker](https://archlinux.org/packages/extra/x86_64/docker/).
- [Paquete PHP](https://archlinux.org/packages/extra/x86_64/php/).
- [Paquete Gum](https://archlinux.org/packages/extra/x86_64/gum/).
- [Paru en CachyOS](https://packages.cachyos.org/package/cachyos/x86_64/paru).
- [VS Code binario en AUR](https://aur.archlinux.org/packages/visual-studio-code-bin).
- [Chrome en AUR](https://aur.archlinux.org/packages/google-chrome).

- [Docker para Ubuntu](https://docs.docker.com/engine/install/ubuntu/).
- [VS Code para Linux](https://code.visualstudio.com/docs/setup/linux).
- [Gum](https://github.com/charmbracelet/gum#installation).
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch#installation).

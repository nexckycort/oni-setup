# Oni Setup: A personal, opinionated setup for Ubuntu and Arch Linux — just how I like it.

**Oni Setup** is my personal and opinionated configuration for Ubuntu and
Arch Linux (including CachyOS), designed to automate the installation and setup
of essential terminal and desktop tools, as well as the application of custom
dotfiles.

This setup is based on the excellent work of Basecamp's
[Omakub project](https://github.com/basecamp/omakub).

---

## Requirements

- Ubuntu 24.04, 26.04, or 26.10; Arch Linux; or CachyOS (x86_64)
- Internet connection to download packages and dotfiles
- User with sudo privileges

---

## Installation

Run the bootstrap script. It automatically detects your distribution:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/nexckycort/oni-setup/main/boot.sh)"
```

---

## License

This repository is for personal use. Feel free to use it as inspiration for your
own dotfiles, but please customize it to suit your needs.

if ! command -v code >/dev/null 2>&1 && ! package_installed code; then
  apt_vendor_repo vscode https://packages.microsoft.com/keys/microsoft.asc \
    https://packages.microsoft.com/repos/code stable main
  packages code
fi
if ! command -v google-chrome >/dev/null 2>&1 && ! package_installed google-chrome-stable; then
  apt_vendor_repo chrome https://dl.google.com/linux/linux_signing_key.pub \
    https://dl.google.com/linux/chrome/deb/ stable main
  packages google-chrome-stable
fi

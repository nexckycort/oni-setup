#!/usr/bin/env bash
# Prueba solo la detección con archivos temporales, sin ejecutar instaladores.
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEST_DIR"' EXIT
passed=0

run_detector() (
  set -eu
  source "$ROOT/install/common/distro.sh"
  uname() { printf '%s\n' "$test_architecture"; }
  detect_distro "$1" || exit 1
  printf '%s:%s:%s' "$DISTRO_ID" "$DISTRO_FAMILY" "$DISTRO_CODENAME"
)

check_detection() {
  local label=$1 content=$2 expected=$3 test_architecture=${4:-x86_64}
  local output status=0
  printf '%b' "$content" > "$TEST_DIR/os-release"
  output=$(run_detector "$TEST_DIR/os-release" 2> "$TEST_DIR/error") || status=$?
  if [[ $expected == reject ]]; then
    if [[ $status -eq 0 || -n $output ]]; then
      printf 'FALLO: %s debía rechazarse.\n' "$label" >&2
      exit 1
    fi
  elif [[ $status -ne 0 || $output != "$expected" ]]; then
    printf 'FALLO: %s; esperado=%s; recibido=%s\n' "$label" "$expected" "$output" >&2
    cat "$TEST_DIR/error" >&2
    exit 1
  fi
  passed=$((passed + 1))
  printf 'OK: %s\n' "$label"
}

check_detection 'Ubuntu 24.04' 'ID=ubuntu\nVERSION_ID=24.04\nVERSION_CODENAME=noble\n' 'ubuntu:ubuntu:noble'
check_detection 'Ubuntu 26.04' 'ID=ubuntu\nVERSION_ID=26.04\nVERSION_CODENAME=resolute\n' 'ubuntu:ubuntu:resolute'
check_detection 'Ubuntu 26.10' 'ID=ubuntu\nVERSION_ID=26.10\nVERSION_CODENAME=stonking\n' 'ubuntu:ubuntu:stonking'
check_detection 'Arch Linux' 'ID=arch\n' 'arch:arch:'
check_detection 'CachyOS' 'ID=cachyos\nID_LIKE=arch\n' 'cachyos:arch:'
check_detection 'Ubuntu 22.04 no admitido' 'ID=ubuntu\nVERSION_ID=22.04\n' reject
check_detection 'Ubuntu desconocido' 'ID=ubuntu\nVERSION_ID=99.04\n' reject
check_detection 'Linux Mint no admitido' 'ID=linuxmint\nID_LIKE="ubuntu debian"\n' reject
check_detection 'Manjaro no admitido' 'ID=manjaro\nID_LIKE=arch\n' reject
check_detection 'Debian no admitido' 'ID=debian\n' reject
check_detection 'os-release vacío' '' reject
check_detection 'Arquitectura no admitida' 'ID=arch\n' reject aarch64

test_architecture=x86_64
if run_detector "$TEST_DIR/missing-os-release" > "$TEST_DIR/output" 2> "$TEST_DIR/error"; then
  echo 'FALLO: debía rechazar un os-release inexistente.' >&2
  exit 1
fi
passed=$((passed + 1))
printf 'OK: os-release inexistente\n\n%d pruebas correctas. No se ejecutó ningún instalador.\n' "$passed"

#!/usr/bin/env bash

# curl https://raw.githubusercontent.com/aurorarissime/linuxstuff/main/script.sh | sh
# Installs Paru, BlackArch, Zen Twilight, Equibop, Quickshell, and Rust Nightly using Mise.

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
	echo "Run this script as a normal user with sudo." >&2
	exit 1
fi

command -v sudo >/dev/null 2>&1 || {
	echo "sudo is required." >&2
	exit 1
}

echo "--- Starting BlackArch installation via strap.sh ---"
curl -fsSLO https://blackarch.org/strap.sh
# Verify the SHA1 sum (00688950aaf5e5804d2abebb8d3d3ea1d28525ed)
echo 00688950aaf5e5804d2abebb8d3d3ea1d28525ed strap.sh | sha1sum -c
chmod +x strap.sh
# Run strap.sh as root
sudo ./strap.sh

rm strap.sh
echo "--- Enabling multilib repository (Manual step required) ---"
echo "# Please manually edit /etc/pacman.conf to enable the [multilib] repository as per Arch Wiki."
# After enabling multilib, run: sudo pacman -Syu
sudo pacman -Syu --needed --noconfirm base-devel git mise  # Full sync after adding BlackArch and enabling multilib

echo "--- BlackArch installation steps completed ---"

mise install rust@nightly

workdir="$(mktemp -d)"
trap 'rm -rf -- "$workdir"' EXIT

git clone https://aur.archlinux.org/paru.git "$workdir/paru"
cd "$workdir/paru"

mise exec rust@nightly -- makepkg -dsi --noconfirm

paru -S --noconfirm --needed zen-twilight-bin

paru -S --noconfirm --needed equibop-bin

sudo pacman -S --noconfirm --needed quickshell
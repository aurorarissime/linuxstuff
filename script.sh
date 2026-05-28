#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
	echo "Run this script as a normal user with sudo." >&2
	exit 1
fi

command -v sudo >/dev/null 2>&1 || {
	echo "sudo is required." >&2
	exit 1
}

sudo pacman -Syu --needed --noconfirm base-devel git mise
hash -r

mise install rust@nightly

workdir="$(mktemp -d)"
trap 'rm -rf -- "$workdir"' EXIT

git clone https://aur.archlinux.org/paru.git "$workdir/paru"
cd "$workdir/paru"

mise exec rust@nightly -- makepkg -dsi --noconfirm

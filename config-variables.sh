#!/bin/bash

# server or desktop
install_mode="server"

################################################################################
# Default variables
################################################################################

# Colors
W='\e[0m'  # White
R='\e[91m' # Red
G='\e[92m' # Green
B='\e[96m' # Blue
Y='\e[93m' # Yellow

# LVM Configuration
create_home_fs="true"

lv_swap_size="16G"
lv_root_size="128G"
lv_home_size="100%FREE"

# Configuration
keymap="fr"
hostname="laptop"
timezone="Europe/Paris"
locale="en_US"
username="david"

# Default packages
declare -a default_packages=(
    "ansible"
    "bash-completion"
    "dmidecode"
    "ethtool"
    "git"
    "htop"
    "inetutils"
    "jq"
    "mlocate"
    "nftables"
    "openbsd-netcat"
    "openssh"
    "tmux"
    "tree"
    "vim"
    "wget"
)

################################################################################
# Desktop variables
################################################################################

# Gnome favorite apps
# Can be found in /usr/share/applications/
favorite_apps="['org.gnome.Terminal.desktop', 'nautilus.desktop', 'brave-browser.desktop', 'vivaldi-stable.desktop', 'firefox.desktop', 'visual-studio-code.desktop', 'notion-app.desktop', 'spotify.desktop', 'slack.desktop', 'discord.desktop', 'scummvm.desktop']"

# Desktop specific packages
declare -a desktop_packages=(
    "alsa-utils"
    "android-tools"
    "argocd"
    "aws-cli-v2"
    "bind"
    "bluez"
    "bluez-utils"
    "brasero"
    "btrfs-progs"
    "chromium"
    "cups"
    "cups-pdf"
    "discord"
    "docker"
    "dosbox"
    "eksctl"
    "elfutils"
    "evince"
    "exfat-utils"
    "filezilla"
    "firefox"
    "fprintd"
    "gdm"
    "gimp"
    "github-cli"
    "gnome"
    "gnome-tweaks"
    "go"
    "gparted"
    "helm"
    "ipcalc"
    "iwd"
    "k9s"
    "kubeadm"
    "kubectl"
    "kubeseal"
    "kustomize"
    "libdwarf"
    "libreoffice-fresh-fr"
    "mimir"
    "minio"
    "minio-client"
    "networkmanager"
    "nfs-utils"
    "obs-studio"
    "packer"
    "prometheus"
    "python-cookiecutter"
    "python-pre-commit"
    "python-pylint"
    "qt5-wayland"
    "rust"
    "rust-analyzer"
    "rust-wasm"
    "rxvt-unicode"
    "scummvm"
    "shellcheck"
    "terraform"
    "unrar"
    "unzip"
    "usbutils"
    "vagrant"
    "valgrind"
    "vault"
    "virtualbox"
    "virtualbox-guest-utils"
    "virtualbox-host-modules-arch"
    "vivaldi"
    "vivaldi-ffmpeg-codecs"
    "vlc"
    "wasmtime"
    "webp-pixbuf-loader"
    "wireguard-tools"
    "wireless_tools"
    "xdg-desktop-portal"
    "xdg-desktop-portal-gnome"
    "xorg"
    "xorg-server"
    "yamllint"
    "zig"
    "zip"
    "zsh"
)

# AUR packages
declare -a aur_packages=(
    "1password"
    "brave-bin"
    "chrome-gnome-shell"
    "cilium-cli-bin"
    "cura-bin"
    "grpcurl-bin"
    "helm-docs"
    "hubble-bin"
    "kind"
    "kube-bench-bin"
    "kube-hunter-bin"
    "kubent-bin"
    "kubescape-bin"
    "notion-app"
    "oh-my-zsh-git"
    "protonvpn-gui"
    "slack-desktop"
    "terraform-docs-bin"
    "tfk8s"
    "tflint-bin"
    "tfsec"
    "visual-studio-code-bin"
    "zsh-theme-powerlevel10k-git"
)

# archlinux-installer

## Description

This is custom installer script for Arch Linux.

![screenshot](https://raw.githubusercontent.com/dotdc/media/main/archlinux-installer/archlinux-installer-screenshot.png "Archlinux-installer screenshot")

It has been made for my personnal use, but could help you build your own.

This installer will:

- Format your disk and create 2 partitions:
  - A partition for the `EFI` (mounted on `/boot`)
  - A `LUKS` encrypted partition for the system
- Configure LVM on LUKS with 3 Logical Volumes (LVs):
  - `/root`
  - `/home`
  - `swap`
- Configure the system
- Create a user/password
- Change the root password
- Install packages, `yay` and some `AUR` packages
- Install the `systemd-boot` bootloader (no support for bios)
- Set custom `Gnome` favorites apps
- Install my [dotfiles](https://github.com/dotdc/dotfiles)

⚠️ This installer will format your disk! I will not be responsible for any data loss or damage to your computer.

## Configuration Files

| File           | Purpose   |
|------------------------------|-----------|
| `config-variables.sh`        | Main configuration file (locale, timezone, user, hostname...) |
| `config-pacman-packages.txt` | List of packages to install |
| `config-pacman-packages.txt` | List of AUR packages to build & install|

## Usage

Once you have booted on Archlinux ISO :

```console
loadkeys fr
pacman -Sy git
git clone https://github.com/dotdc/archlinux-installer
cd archlinux-installer
./archlinux-installer.sh
```

Then follow the steps!

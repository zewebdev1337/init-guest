#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Update
sudo pacman -Syyu

# Install needed packages
sudo pacman -S spice-vdagent qemu-guest-agent git pacman-contrib zip xdg-user-dirs xfce4-whiskermenu-plugin vlc gimp telegram-desktop gnome-disk-utility baobab galculator p7zip catfish syncthing gpick chromium firefox gparted keepassxc gpa pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394 libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader imagemagick reflector docker vultr-cli github-cli tree
# Check if gvfs-smb is actually needed.
# gvfs-smb

# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
sudo rm -rf ./yay-bin

# Install needed AUR packages
yay -S visual-studio-code-bin nvm dockbarx xfce4-dockbarx-plugin vercel syncthingtray act noto-fonts-emoji


# gnome-keyring
## INSTALL AFTER PACMAN INSTALLS EVERYTHING
## FIX: LOGIN TO USER, LAUNCH CHROMIUM, INSTALL GNOME-KEYRING, CLOSE AND REOPEN CHROMIUM, SET PASSWORD FOR KEYRING, CLOSE CHROMIUM, REBOOT, PROFIT
sudo pacman -S gnome-keyring 

# OUTDATED NOTE: gnome keyring bug all through October 2023: whichever user profile logins first (maybe it's first profile to launch chromium but I lean more towards first login. It's been a pain in the ass, so not a lot of willingness to test further left in me) after first boot is the only one able to use the keyring, further, the accounts that can't use the keyring can't open chromium as it crashes on boot after the GPU error message (this GPU error shows regularly, even when it boots without issues but it logs more stuff past that point when it does. On bugged accounts it stops at the GPU error). Uninstalling gnome-keyring doesn't fix the issue. If gnome-keyring is not installed, all users can boot chromium up
# gnome-keyring


# Clean pacman & yay caches
sudo paccache -rk0
sudo rm -rf ~/.cache/yay/*

exit 

#########################################################
#                          ROOT                         #
#########################################################

# Switch to root for operations that can only be done as root
su

# Enable based downloads
sed -i '/^#ParallelDownloads/s/^#//; /^ParallelDownloads/s/=.*/= 32/' /etc/pacman.conf

# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf

# Install new-repo-from-template
curl -LJO https://raw.githubusercontent.com/zewebdev1337/new-repo-from-template/main/new-repo-from-template.sh
chmod +x new-repo-from-template.sh
mv new-repo-from-template.sh /usr/local/bin/new-repo-from-template

# Create folder thumbnailer
echo '#!/bin/bash
 
convert -thumbnail "$1" "$2/folder.png" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/.folder.png" "$3" 1>/dev/null 2>&1 ||\
rm -f "$HOME/.cache/thumbnails/normal/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.thumbnails/normal/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.cache/thumbnails/large/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
rm -f "$HOME/.thumbnails/large/$(echo -n "$4" | md5sum | cut -d " " -f1).png" ||\
exit 1' >> /usr/bin/folder-thumbnailer
echo '[Thumbnailer Entry]
Version=1.0
Encoding=UTF-8
Type=X-Thumbnailer
Name=Folder Thumbnailer
MimeType=inode/directory;
Exec=/usr/bin/folder-thumbnailer %s %i %o %u' >> /usr/share/thumbnailers/folder.thumbnailer

# Mark folder thumbnailer as executable
chmod +x /usr/bin/folder-thumbnailer
chmod +x /usr/share/thumbnailers/folder.thumbnailer

exit

 
#########################################################
#                          USER                         #
#########################################################
 
# Switch to user for operations that need to be done as non-sudo user
 
# Bash

echo 'HISTFILESIZE=10000
HISTSIZE=10000
HISTTIMEFORMAT="%F %T "
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s histappend
' >> ~/.bashrc
echo 'alias index-updater="react-index-updater & svelte-index-updater & js-index-updater"' >> ~/.bashrc
echo 'alias vultr-inst="vultr-cli instance list"' >> ~/.bashrc
echo 'export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_git_ed25519 -o IdentitiesOnly=yes"' >> ~/.bashrc

# Desktop Environment Settings

gsettings set org.gnome.desktop.interface color-scheme prefer-dark
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/theme -s Crux
xfconf-query -c xfwm4 -p /general/easy_click -s none

# Enable Syncthing
systemctl enable --now syncthing.service --user
systemctl enable --now docker.socket
# Note that docker.service starts the service on boot, whereas docker.socket starts docker on first usage
#systemctl enable --now docker.service

# Setup and start nvm
echo '
source /usr/share/nvm/init-nvm.sh
' >> ~/.bashrc
source /usr/share/nvm/init-nvm.sh

# Install Node.js LTS
nvm install lts/*

# Install global npm packages
npm install --global  @zewebdev/react-index-updater @zewebdev/svelte-index-updater web-ext @railway/cli @remix-project/remixd npm-check-updates vsce # @zewebdev/js-index-updater 

# Set needed git variables
git config --global init.defaultBranch "main"
git config --global user.name "zewebdev1337"
keepassxc &
syncthingtray &
# git config --global user.email "secretgithubemail@users.noreply.github.com"

# Enable emoji support 🤗
mkdir -p ~/.config/fontconfig/conf.d
echo '<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Use Google Emojis -->
  <match target="pattern">
    <test qual="any" name="family"><string>Segoe UI Emoji</string></test>
    <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
  </match>
</fontconfig>' >> ~/.config/fontconfig/conf.d/01-emoji.conf

#########################################################
#                          UTIL                         #
#########################################################

# Fix mirrors (pacman/yay slow download)
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
# sudo reflector --country 'United States' --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

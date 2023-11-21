#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Update
sudo dnf upgrade --refresh

# Install needed repos
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Repo for VSCode
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

# Import VSCode repo
sudo dnf check-update
sudo dnf install gh code git vlc gimp telegram-desktop docker vultr-cli baobab galculator p7zip syncthing gpick chromium keepassxc samba-client gvfs-smb lirc protobuf vcdimager libva-intel-driver libva-vdpau-driver libopenraw
# older arch packages, most for vlc sudo dnf install pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394 libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader imagemagick reflector docker vultr-cli github-cli
 
# build fails on fedora via dnf
# dockbarx xfce4-dockbarx-plugin 

# Cleanup
sudo dnf clean all

exit 

#########################################################
#                          ROOT                         #
#########################################################

# Switch to root for operations that can only be done as root
su

# Add non-sudo user
useradd user -m
usermod -aG docker user
passwd user

# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf

# Create folder thumbnailer
echo '#!/bin/bash
 
convert -thumbnail "$1" "$2/folder.jpg" "$3" 1>/dev/null 2>&1 ||\
convert -thumbnail "$1" "$2/.folder.jpg" "$3" 1>/dev/null 2>&1 ||\
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
 
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/theme -s Crux
xfconf-query -c xfwm4 -p /general/easy_click -s none
echo "alias npm='npm '" >> ~/.bashrc
echo "alias audit='audit --omit=dev'" >> ~/.bashrc
echo "alias indexupd='react-index-updater & svelte-index-updater & js-index-updater'" >> ~/.bashrc
#echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
# TODO: Check if xcape is fixed. it triggers multiple Alt+F1 inputs in quick succession as opposed to a single input as of lately. getting used to using Alt+F1 tho.
# Enable Syncthing
systemctl enable --now syncthing.service --user
systemctl enable --now docker.service
# Note that docker.service starts the service on boot, whereas docker.socket starts docker on first usage
#systemctl enable --now docker.socket
# Get and start nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash   
source ~/.bashrc
# Install Node.js LTS
nvm install lts/*
# Install index updaters
npm install --global @zewebdev/react-index-updater @zewebdev/svelte-index-updater web-ext
# @zewebdev/js-index-updater 
# Set needed git variables
git config --global init.defaultBranch "main"
git config --global user.name "zewebdev1337"
# Get email
keepassxc &
firefox http://localhost:8384 &
firefox https://github.com/settings/emails &

# git config --global user.email "secretgithubemail@users.noreply.github.com"
# Disable bash history
echo 'export HISTSIZE=0' >> ~/.bashrc
# Update
sudo pacman -Syyu

# Install needed packages
sudo pacman -S spice-vdagent pacman-contrib zip xdg-user-dirs xfce4-whiskermenu-plugin vlc gimp xcape gnome-keyring telegram-desktop
sudo pacman -S gnome-disk-utility baobab galculator p7zip catfish syncthing gpick chromium firefox gparted keepassxc

# Install all of VLCs optional dependencies to fix fucked video playback -no kwallet
sudo pacman -S pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394

# Create user folders
xdg-user-dirs-update

# Enable Super key & TRIM
xcape -e 'Super_L=Alt_L|F1'
sudo systemctl enable --now fstrim.timer

# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
# Remove yay's source folder
sudo rm -rf ./yay-bin

# Install needed AUR packages
yay -S visual-studio-code-bin nvm

# Clean pacman & yay caches
sudo paccache -rk0
sudo rm -rf ~/.cache/yay/*

# Operations that need to be performed as root
su
# Disable bash history
echo 'export HISTSIZE=0' >> ~/.bashrc
# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf
# Dummy swap entry in fstab (hasn't been needed since RAM upgrade, also swapping on linux sucks and the system is very likely to hardlock/kill essential processes even at 200 swappiness)
# echo '#Dummy swap partition entry with priority /dev/sdb2 none swap defaults,pri=99  0 0' >> /etc/fstab
exit

# Operations that need to performed as 'user'
su - user
# Disable bash history
echo 'export HISTSIZE=0' >> ~/.bashrc
# Enable Syncthing
systemctl enable --now syncthing.service --user
#Set and start nvm
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
source /usr/share/nvm/init-nvm.sh
#Install Node.js LTS
nvm install 18
# Set needed git variables
# git config --global user.email "secretgithubemail@users.noreply.github.com"
git config --global user.name "zewebdev1337"

echo 'Before finishing, you need to copy the secretgithubemail@users.noreply.github.com from Github>Settings>Emails'

# TODO: Block chromium's internet access

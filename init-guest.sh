#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Once in admin acct:
# Update
sudo pacman -Syyu

# Install needed packages
sudo pacman -S spice-vdagent qemu-guest-agent git pacman-contrib zip xdg-user-dirs xfce4-whiskermenu-plugin vlc gimp telegram-desktop gnome-disk-utility baobab galculator p7zip catfish syncthing gpick chromium firefox gparted keepassxc gpa gvfs-smb pcsclite aribb25 aribb24 projectm libgoom2 lirc sdl_image libtiger libkate zvbi lua52-socket libmicrodns protobuf ttf-dejavu smbclient libmtp vcdimager libgme libva-intel-driver libva-vdpau-driver libdc1394 libwmf libopenraw libavif libheif libjxl librsvg webp-pixbuf-loader imagemagick gnome-keyring
# gnome keyring bug all through October 2023: whichever user profile logins first (maybe it's first profile to launch chromium but I lean more towards first login. It's been a pain in the ass, so not a lot of willingness to test further left in me) after first boot is the only one able to use the keyring, further, the accounts that can't use the keyring can't open chromium as it crashes on boot after the GPU error message (this GPU error shows regularly, even when it boots without issues but it logs more stuff past that point when it does. On bugged accounts it stops at the GPU error). Uninstalling gnome-keyring doesn't fix the issue. If gnome-keyring is not installed, all users can boot chromium up

# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
# Remove yay's source folder
sudo rm -rf ./yay-bin

# Install needed AUR packages
yay -S visual-studio-code-bin nvm dockbarx xfce4-dockbarx-plugin 

# Clean pacman & yay caches
sudo paccache -rk0
sudo rm -rf ~/.cache/yay/*

exit 

#########################################################
#                          ROOT                         #
#########################################################

# Switch to root for operations that can only be done as root
su
# Set swappiness
echo 'vm.swappiness = 200' >> /etc/sysctl.d/99-swappiness.conf
# Dummy swap entry in fstab (hasn't been needed since RAM upgrade, also swapping on linux sucks and the system is very likely to hardlock/kill essential processes even at 200 swappiness)
# echo '#Dummy swap partition entry with priority /dev/sdb2 none swap defaults,pri=99  0 0' >> /etc/fstab
exit

 
#########################################################
#                          USER                         #
#########################################################
 
# Switch to user for operations that need to be done as non-sudo user
 
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/theme -s Crux
xfconf-query -c xfwm4 -p /general/easy_click -s none
alias audit='audit --omit=dev'
#echo "xcape -e 'Super_L=Alt_L|F1'" >> ~/.bashrc
# Enable Syncthing
systemctl enable --now syncthing.service --user
#Set and start nvm
echo 'source /usr/share/nvm/init-nvm.sh' >> ~/.bashrc
source /usr/share/nvm/init-nvm.sh
#Install Node.js LTS
nvm install 20
# Set needed git variables
git config --global user.name "zewebdev1337"
# Get email
keepassxc &
firefox http://localhost:8384 &
firefox https://github.com/settings/emails &

# git config --global user.email "secretgithubemail@users.noreply.github.com"

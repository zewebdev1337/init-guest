#########################################################
#                         ADMIN                         #
#########################################################
 
# Switch to admin account
su - admin
 
# Update
sudo pacman -Syyu

# Install needed packages
sudo pacman -S pacman-contrib reflector smbclient lsof git expect

# Install yay
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..
sudo rm -rf ./yay-bin

# Install needed AUR packages
yay -S plex-media-server

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

# Add required network shares to fstab
echo '//master/server           /server         cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/warez            /media/root     cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/media-2tb        /media/2tb      cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/media-500g       /media/500g     cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/media-samsung    /media/samsung  cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/media-timetec    /media/timetec  cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0
//master/media-micron     /media/micron   cifs    rw,_netdev,uid=1000,iocharset=utf8,password=guest   0 0' >> /etc/fstab

# Autologin as user
mkdir /etc/systemd/system/getty@tty1.service.d/
touch /etc/systemd/system/getty@tty1.service.d/override.conf
echo '[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin user --noclear %1 $TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf

# Set static IP Address
rm -rf /etc/systemd/network/20-ethernet.network
echo '[Match]
# Matching with "Type=ether" causes issues with containers because it also matches virtual Ethernet interfaces (veth*).
# See https://bugs.archlinux.org/task/70892
# Instead match by globbing the network interface name.
Name=en*
Name=eth*

[Network]
DHCP=no
# FOR BRIDGE CONNECTION: Address=192.168.100.250/24
Address=192.168.122.50/24
Gateway=192.168.122.1
IPv6PrivacyExtensions=yes

# systemd-networkd does not set per-interface-type default route metrics
# https://github.com/systemd/systemd/issues/17698
# Explicitly set route metric, so that Ethernet is preferred over Wi-Fi and Wi-Fi is preferred over mobile broadband.
# Use values from NetworkManager. From nm_device_get_route_metric_default in
# https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/src/core/devices/nm-device.c
[DHCPv4]
RouteMetric=100

[IPv6AcceptRA]
RouteMetric=100' >> /etc/systemd/network/20-ethernet.network

# Check https://wiki.archlinux.org/title/plex and verify if ssh tunnel is required or no

# Share watcher/remounter script
echo '#!/usr/bin/expect

set DRIVE_PATH "/media/500g/"
set TEST_PATH "/media/500g/Music/"

while {1} {
    if([file exists $TEST_PATH]){
        puts "$TEST_PATH found, drive is mounted."
    } else {
        puts "$TEST_PATH not found, remounting drive..."
        spawn umount $DRIVE_PATH
        expect eof

        spawn mount -a
        expect eof
    }
    sleep 10
}' >> /smb.sh
chmod +x /smb.sh

# Share watcher/remounter service
echo '[Unit]
Description=Periodically check and remount SMB share(s) if necessary.
After=network.target

[Service]
ExecStart=/bin/bash /smb.sh
Restart=always

[Install]
WantedBy=default.target' >> /etc/systemd/system/smb-remounter.service

systemctl enable --now smb-remounter.service

exit

#########################################################
#                          USER                         #
#########################################################
 
# Switch to user for operations that need to be done as non-sudo user

systemctl enable --now plexmediaserver.service
systemctl enable --now nginx.service

#########################################################
#                          UTIL                         #
#########################################################

# Fix mirrors (pacman/yay slow download)
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
# sudo reflector --country 'United States' --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

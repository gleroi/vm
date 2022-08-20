set -x

source /etc/profile

# setup root with no password
cat <<EOF | passwd root
root
root
EOF

passwd -S root

# empty fstab
echo "" > /etc/fstab

# setup networkd
cat > /etc/systemd/network/ethernet.network <<EOF
[Match]
Name = en*

[Network]
DHCP=yes
MulticastDNS=resolve
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved


# exherbo basic config
echo "exherbo-1" > /etc/hostname
localedef -i en_US -f ISO-8859-1 en_US
echo LANG="en_US.UTF-8" > /etc/env.d/99locale
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime

# exherbo package manager sync
cave sync
cave update-world app-editors/vim sys-apps/iproute2

df -h

# this fail on deleting sudo, nothings happens, no error msg ???
#cave --log-level debug purge -x

# delete self
rm -f /root/setup.sh

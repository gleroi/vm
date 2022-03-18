# setup root with no password
passwd --delete root

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

ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# delete self
rm -f /root/setup.sh

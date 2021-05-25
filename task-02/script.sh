#!/bin/bash
sudo apt-get install -y lxc lxc-templates
cat <<EOF | tee -a /etc/default/lxc-net
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.1.1.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.1.1.0/24"
LXC_DHCP_RANGE="10.1.1.2,10.1.1.254"
LXC_DHCP_MAX="253"
LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf
LXC_DOMAIN=""
EOF

cat <<EOF | tee /etc/lxc/dnsmasq.conf
dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf
EOF

cat <<EOF | tee /etc/lxc/dnsmasq-hosts.conf
centos1,10.1.1.100
centos2,10.1.1.101
EOF

sudo mkdir -p /var/lib/lxd/networks/lxcbr0/
cat <<EOF | tee /var/lib/lxd/networks/lxcbr0/dnsmasq.hosts
10.1.1.100,centos1
10.1.1.101,centos2
EOF

sudo mkdir -p /etc/dnsmasq.d-available/
cat <<EOF | tee /etc/dnsmasq.d-available/lxc
bind-interfaces
except-interface=lxcbr0
EOF

sudo systemctl enable lxc-net
sudo systemctl start lxc-net

cat <<EOF | tee /etc/lxc/default.conf
lxc.net.0.type  = veth
lxc.net.0.flags = up
lxc.net.0.link  = lxcbr0
lxc.apparmor.profile = unconfined
EOF

sudo lxc-create -t download -n centos1 -- -d centos -r 8 -a amd64
sudo lxc-create -t download -n centos2 -- -d centos -r 8 -a amd64
sudo lxc-start -n centos1
sudo lxc-start -n centos2
sleep 50
sudo lxc-attach centos1 -- yum -y install httpd
sudo lxc-attach centos1 -- systemctl enable httpd
sudo lxc-attach centos1 -- systemctl start httpd
sudo lxc-attach centos2 -- yum -y install httpd
sudo lxc-attach centos2 -- yum -y install php
sudo lxc-attach centos2 -- systemctl enable httpd
sudo lxc-attach centos2 -- systemctl start httpd

sudo mv /vagrant/01-demosite-static /var/lib/lxc/centos1/rootfs/var/www/html/01-demosite-static
cat <<EOF | sudo tee /var/lib/lxc/centos1/rootfs/etc/httpd/conf.d/01-demosite-static.conf
<VirtualHost *:80>
        ServerAdmin serg@localhost
        DocumentRoot /var/www/html/01-demosite-static
        DirectoryIndex index.html
</VirtualHost>
EOF

sudo mv /vagrant/01-demosite-php /var/lib/lxc/centos2/rootfs/var/www/html/01-demosite-php
cat <<EOF | sudo tee /var/lib/lxc/centos2/rootfs/etc/httpd/conf.d/01-demosite-php.conf
<VirtualHost *:81>
        ServerAdmin serg@localhost
        DocumentRoot /var/www/html/01-demosite-php
        DirectoryIndex index.php
</VirtualHost>
EOF

sudo sed -i '/Listen 80/a Listen 81' /var/lib/lxc/centos2/rootfs/etc/httpd/conf/httpd.conf
sudo rm /var/lib/lxc/centos1/rootfs/etc/httpd/conf.d/welcome.conf
sudo rm /var/lib/lxc/centos2/rootfs/etc/httpd/conf.d/welcome.conf
sudo lxc-attach centos1 -- systemctl restart httpd
sudo lxc-attach centos2 -- systemctl restart httpd

centos1_ip=$(sudo lxc-info -i -n centos1 | cut -d : -f 2)
centos2_ip=$(sudo lxc-info -i -n centos2 | cut -d : -f 2)
sudo iptables -F
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination ${centos1_ip}:80
sudo iptables -t nat -I PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to-destination ${centos2_ip}:81

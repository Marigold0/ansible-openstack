#!/bin/bash

set -e

home_dir=/home/$USER
apt_path=/etc/apt/sources.list.d/
dir_path=/srv/openstack-airgap
port=8085

#sudo mkdir -p $home_dir/repo-backups/ | sudo mv $apt_path* $home_dir/repo-backups/

# Membuat link dari directory ansible-openstack ke path /srv/
if [ -L "$dir_path" ]; then
    echo "Symlink $dir_path sudah ada, skip..."
elif [ -d "$dir_path" ]; then
    echo "Direktori $dir_path sudah ada, skip..."
else
    echo "Membuat symlink $dir_path..."
    sudo ln -s ~/ansible-openstack/openstack-airgap/ /srv/
fi

# Menambahkan Sources List
sudo tee /etc/apt/sources.list.d/openstack-airgap.list << EOF > /dev/null
deb [trusted=yes] file:$dir_path/repo ./

EOF

sudo apt update &&
sudo apt install nginx -y

sudo tee /etc/nginx/sites-available/ubuntu-openstack-mirror << EOF > /dev/null
server {
    listen $port;
    server_name _;

    root $dir_path;
    
    disable_symlinks off;

    location / {
        autoindex on;
    }
}

EOF

sudo usermod -aG $USER www-data

sudo systemctl restart nginx

echo "---------------------------------------------------"
echo "Kamu Juga bisa akses via web ke http://IPADDR:$port"
 


#!/bin/bash

sudo apt update
sudo apt install -y apache2-utils nginx

sudo htpasswd -cb /etc/.htpasswd admin 'your_password_here'

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/nn

cat <<EOF | sudo tee /etc/nginx/sites-available/nn
server {
    listen 9870;
    location / {
        auth_basic "Administrator's Area";
        auth_basic_user_file /etc/.htpasswd;
        proxy_pass http://team-20-nn:9870;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/nn /etc/nginx/sites-enabled/nn
sudo nginx -t && sudo systemctl reload nginx
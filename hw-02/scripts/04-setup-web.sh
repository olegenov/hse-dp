#!/bin/bash

sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/ya
sudo cp /etc/nginx/sites-available/nn /etc/nginx/sites-available/dh

sudo sed -i 's/listen 9870;/listen 8088;/; s/9870/8088/' /etc/nginx/sites-available/ya
sudo sed -i 's/listen 9870;/listen 19888;/; s/9870/19888/' /etc/nginx/sites-available/dh

sudo ln -sf /etc/nginx/sites-available/ya /etc/nginx/sites-enabled/ya
sudo ln -sf /etc/nginx/sites-available/dh /etc/nginx/sites-enabled/dh
sudo nginx -t && sudo systemctl reload nginx
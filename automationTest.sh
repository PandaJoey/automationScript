#!/bin/bash

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential
sudo apt-get -y install nginx
sudo service nginx start
sudo apt-get -y install nodejs
sudo apt-get -y install npm
sudo apt-get -y install virtualbox
sudo apt-get -y install vagrant 
sudo vagrant box add ubuntu/bionic64
mkdir vagrantboxes
sudo chown -R ubuntu vagrantboxes/
cd vagrantboxes
vagrant init ubuntu/bionic64
#git clone https://github.com/PandaJoey/vagrantTestScript.git
#cd vagrantTestScript/
vagrant up
#need to change the file here some how
ip="$(ifconfig | grep wlp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
#ip="$(ifconfig | grep enp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
echo "upstream app_Hello {
        server $ip:3014;
}

server {
        listen 80;
        server_name l.hellovm.akerolabs.com;
        access_log /var/log/nginx/hello-admin.log;
        location / {
                proxy_set_header X-Real-IP ;
                proxy_set_header X-Forwarded-For ;
                proxy_set_header Host ;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade ;
                proxy_set_header Connection upgrade;
                proxy_pass http://app_Hello/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}" > hello-app.txt
sudo mv hello-app.txt /etc/nginx/sites-enabled/
sudo nginx -s stop
sudo service nginx start
sudo npm install -y
sudo node app.js &

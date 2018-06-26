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
sudo vagrant box add ubuntu/bionic64 --force
mkdir /home/joe/test/vagrantboxes
sudo chown -R joe /home/joe/test/vagrantboxes
cd /home/joe/test/vagrantboxes
sudo vagrant init ubuntu/bionic64
sudo vagrant up
#git clone https://github.com/PandaJoey/vagrantTestScript.git
#cd vagrantTestScript/
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
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade $https_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://app_Hello/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}" > hello-app
sudo mv hello-app.txt /etc/nginx/sites-enabled/
sudo nginx -s stop
sudo service nginx start
sudo mkdir /home/joe/nodeproject/
sudo chown -R joe /home/joe/nodeprojects
cd /home/joe/nodeprojects/
git init
git clone https://github.com/PandaJoey/vagrantTestScript.git
sudo npm install -y
sudo node app.js &

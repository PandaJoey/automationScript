#!/bin/bash
scriptUser=$(whoami)
#sudo su 
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install net-tools
sudo apt-get -y install build-essential
sudo apt-get -y install nginx
sudo nginx -s stop
sudo service nginx start
sudo apt-get -y install nodejs
sudo apt-get -y install npm
sudo apt-get -y install virtualbox
sudo apt-get -y install vagrant
#su - $scriptUser
mkdir /home/$scriptUser/workspace/vagrantboxes
#sudo su
sudo chmod -R +x /home/$scriptUser/workspace/vagrantboxes
sudo chown -R $scriptUser /home/$scriptUser/workspace/vagrantboxes
#su - $scriptUser
cd /home/$scriptUser/workspace/vagrantboxes
git clone https://github.com/PandaJoey/hostSetupFiles.git
cd /
sudo chmod -R +x /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles
sudo chown -R $scriptUser /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles/
cd /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles/
vagrant box add ubuntu/bionic64 --force
vagrant up
#git clone https://githublsl;s.com/PandaJoey/vagrantTestScript.git
#cd vagrantTestScript/
#need to change the file here some how
#ip="$(ifconfig | grep enp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
ip="$(ifconfig | grep wlp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
echo "upstream app_Hello {
        server $ip:3012;
}" >> hello-app
echo 'server {
        listen 80;
        server_name l.hello.akerolabs.com;
        access_log /var/log/nginx/hello-admin.log;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://app_Hello/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}' >> hello-app
echo "upstream app_HelloVm {
        server $ip:3025;
}" >> hellovm-app

echo 'server {
        listen 80;
        server_name l.hellovm.akerolabs.com;
        access_log /var/log/nginx/hello-admin.log;
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_set_header X-NginX-Proxy true;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_pass http://app_HelloVm/;
                proxy_redirect off;
                proxy_http_version 1.1;
                proxy_buffering off;
        }
}' >> hellovm-app
sudo mv hello-app /etc/nginx/sites-enabled/
sudo mv hellovm-app /etc/nginx/sites-enabled/
#sudo su
sudo nginx -s stop
sudo service nginx start
#su - $scriptUser
cd /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/node/
npm install -y
node app.js &





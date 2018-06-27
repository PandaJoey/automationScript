#!/bin/bash
user=$(whoami)

apt-get -y update
apt-get -y upgrade
apt-get -y install net-tools
apt-get -y install build-essential
apt-get -y install nginx
nginx -s stop
service nginx start
apt-get -y install nodejs
apt-get -y install npm
apt-get -y install virtualbox
apt-get -y install vagrant
vagrant box add ubuntu/bionic64 --force
mkdir /home/test/test/vagrantboxes
chmod -R +x /home/test/test/vagrantboxes
chown -R test /home/test/test/vagrantboxes
cd /home/test/test/vagrantboxes
chmod -R +x /home/test/test/vagrantboxes
git init
git clone https://github.com/PandaJoey/hostSetupFiles.git
cd /home/test/test/hostSetUpFiles
vagrant up
#git clone https://github.com/PandaJoey/vagrantTestScript.git
#cd vagrantTestScript/
#need to change the file here some how
ip="$(ifconfig | grep wlp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
#ip="$(ifconfig | grep enp -A 2 | grep inet  | awk '{match($0,/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/); ip = substr($0,RSTART,RLENGTH); print ip}')"
echo "upstream app_Hello {
        server $ip:3012;
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
echo "upstream app_HelloVm {
        server $ip:3025;
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
}" > hellovm-app
mv hello-app /etc/nginx/sites-enabled/
mv hellovm-app /etc/nginx/sites-enabled/
cp -f hosts /etc/hosts
nginx -s stop
service nginx start
mkdir /home/test/test/nodeprojects
chmod -R +x /home/test/test/nodeprojects/
chown -R test /home/test/test/nodeprojects/
cd /home/test/test/hostSetUpFiles/
mv app.js /home/test/test/nodeprojects/
mv package.json /home/test/test/nodeprojects/
mv nodemodules/ /home/test/test/nodeprojects/
cd /home/test/test/nodeprojects/
npm install -y
node app.js &



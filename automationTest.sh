#!/bin/bash
#used to get the user name so can be used in file paths if used on other machines
scriptUser=$(whoami)

#should probably put these in some sort of function to check if they need to be installed rather than just trying to brute
#force install them
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

#creates a directory in the users workspace folder, might need to get some users input for this to ask for a file path
#takes ownship and sets permisions for the file, not sure if nessasary need to test it.
#clones the host files needed for install and takes ownership of the directory
#then installs a box client in this game ubuntu and starts the server.
#on vagrant up the script is stopped partially while the provisions.sh script runs the stuff needed to setup the VM
mkdir /home/$scriptUser/workspace/vagrantboxes
sudo chmod -R +x /home/$scriptUser/workspace/vagrantboxes
sudo chown -R $scriptUser /home/$scriptUser/workspace/vagrantboxes
cd /home/$scriptUser/workspace/vagrantboxes
git clone https://github.com/PandaJoey/hostSetupFiles.git
cd /
sudo chmod -R +x /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles
sudo chown -R $scriptUser /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles/
cd /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/vagrantInitFiles/
vagrant box add ubuntu/bionic64
vagrant up

#creates the nginx sites-enabled files by getting the ip of the host/vm and putting the ip in a file, then moves it to the sites-enabled file
#not sure if both files are required or if its one for each machine depending on the port it needs to access.
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
#this should probably check it see if users already have files there to make sure they are not overwritten
sudo mv hello-app /etc/nginx/sites-enabled/
sudo mv hellovm-app /etc/nginx/sites-enabled/
#restarts ngix to get the sites-enabled files working
sudo nginx -s stop
sudo service nginx start
#starts the node app on the host machine. problems occure if the node app isnt installed more than once on the
#same port, the process has to be killed.
cd /home/$scriptUser/workspace/vagrantboxes/hostSetupFiles/node/
npm install -y
node app.js &






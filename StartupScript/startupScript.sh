#! /bin/sh
sudo apt-get -y update
sudo apt-get -y install nginx
sudo apt -y install python3
sudo apt -y install python3-pip
sudo pip3 install uwsgi
gsutil cp -r gs://autoscalercode/ServerlessAutoscaler /home/marcostaraf
gsutil cp -r gs://autoscalercode/nginx.conf /home/marcostaraf
sudo mv /home/marcostaraf/nginx.conf /etc/nginx
sudo nginx -t
sudo nginx -s stop
sudo nginx
sudo python3 -m pip install django
sudo pip3 install gunicorn
cd /home/marcostaraf/ServerlessAutoscaler/project/coursesite
gunicorn coursesite.wsgi -b 0.0.0.0:8080 --timeout 900 --log-level debug --log-file -

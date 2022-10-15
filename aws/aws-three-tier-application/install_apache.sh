#!/bin/bash

sudo apt update
sudo apt install apache2
sudo su -
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2

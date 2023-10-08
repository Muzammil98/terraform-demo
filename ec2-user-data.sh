#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>This is demo website. $(hostname -f) </h1>" > /var/www/html/index.html
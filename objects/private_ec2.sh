#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install mysql-server -y

sudo sed -i 's/^bind-address/#bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql

sudo mysql -e "CREATE USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

mysql -u root -ppassword <<EOF
CREATE DATABASE aws;
USE aws;
CREATE TABLE s3 (
    name VARCHAR(25) NOT NULL
);
CREATE TABLE dynamodb (
    name VARCHAR(25) NOT NULL
);
EOF

echo "MySQL installation and configuration completed."

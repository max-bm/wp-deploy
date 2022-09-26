#!/bin/bash

# Deploy wordpress from scratch
# INSTALLS AND ENABLES

# Either provide variables as argument inputs in order [url, pwd], or set manually below.
# ip=$(ifconfig ens160 | grep inet | cut -d: -f2 | awk '{print $2}') # This line takes ip from ifconfig - useful for vmware vms
url=$1
dbpass=$2

dnf module reset php -y && dnf module enable php:8.0 -y
dnf install php php-mysqlnd httpd wget -y
systemctl enable --now httpd 

# If option 'm' given, then install and configure mysql database.
while getopts ":m" option; do
	case $option in
		m) # install and configure mysql database
			mysql_install_and_config
			;;
	esac
done

# WORDPRESS INSTALL
cd /var/www && wget http://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz -C /var/www/html
chown -R apache:apache /var/www/html/wordpress

# APPEND TO HTTPD.CONFIG
sed -i 's/DocumentRoot\ "\/var\/www\/html"/DocumentRoot\ "\/var\/www\/html\/wordpress"/g' /etc/httpd/conf/httpd.conf

# INSTALL WODPRESS FROM CLI
cd /var/www/ && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
dnf install php-json -y
cd /var/www/html/wordpress/
/usr/local/bin/wp core config --dbname="wordpress" --dbuser="wordpress" --dbpass="$dbpass" --dbhost="localhost" --dbprefix="wp_"
/usr/local/bin/wp core install --url="http://$url" --title="Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@site.com"
chown apache:apache wp-config.php

# RESTART HTTPD SERVICE
systemctl restart httpd

mysql_install_and_config () {
	dnf install mysql-server -y
	systemctl enable --now mysqld
	# CREATE MYSQL DATABASE
	mysql -e "CREATE DATABASE wordpress;"
	mysql -e "CREATE USER wordpress IDENTIFIED BY '$dbpass';"
	mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress';"
	mysql -e "FLUSH PRIVILEGES;"
}

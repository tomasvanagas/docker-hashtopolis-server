FROM ubuntu:18.04
LABEL authors="Kenneth Peiruza <kenneth@floss.cat>, Tomas Vanagas <tomasvanagas@ymail.com>"

RUN	export DEBIAN_FRONTEND=noninteractive && apt update && apt upgrade -y && apt install -y mysql-server apache2 php-mysql php php-gd php-pear pwgen gcc make autoconf libc-dev libapache2-mod-php php-curl git pkg-config libmcrypt-dev php7.2-dev && \
	printf "\n" | pecl install mcrypt-1.0.1 && \
	echo extension=mcrypt.so >/etc/php/7.2/apache2/php.ini && \
	cd /var/www/ && rm html/index.html && \
	git clone https://github.com/s3inlc/hashtopolis.git && \
	mv hashtopolis/src/* html/ && \
	chown -R www-data:www-data /var/www/html && \
	ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/sterr /var/log/apache2/error.log && \
	echo "ServerName Hashtopolis" > /etc/apache2/conf-enabled/serverName.conf && \
	service mysql start && service apache2 start && \
	MYSQL_PASSWORD="$(cat /etc/mysql/debian.cnf | grep password | tail -n 1 | cut -d'=' -f2 | sed 's/^ //g')" && \
	mysql -udebian-sys-maint -p$MYSQL_PASSWORD -hlocalhost -e "CREATE database hashtopolis;" && \
	cat /var/www/html/inc/conf.template.php | sed 's/INSTALL = false/INSTALL = true/g' | sed 's/__DBUSER__/debian-sys-maint/g' | sed "s/__DBPASS__/$MYSQL_PASSWORD/g" |sed 's/__DBSERVER__/localhost/g' |sed 's/__DBDB__/hashtopolis/g' | sed 's/__DBPORT__/3306/g' > /var/www/html/inc/conf.php && \
	chown  www-data:www-data /var/www/html/inc/conf.php

EXPOSE 80

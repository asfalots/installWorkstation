#!/usr/bin/env bash

PHP_VERSION="5.5"
PSQL_VERSION="9.4"


wget http://downloads.zend.com/zendserver/8.0.0/ZendServer-8.0.0-RepositoryInstaller-linux.tar.gz
tar zxvf ZendServer-8.0.0-RepositoryInstaller-linux.tar.gz
./ZendServer-RepositoryInstaller-linux/install_zs.sh $PHP_VERSION --automatic


echo 'export PATH=$PATH:/usr/local/zend/bin' >> /etc/profile.d/zend-server.sh
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/zend/lib' >> /etc/profile.d/zend-server.sh

curl -sS https://getcomposer.org/installer | /usr/local/zend/bin/php -- --install-dir=/usr/bin --filename=composer

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgres.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get upgrade
apt-get install -y postgresql-$PSQL_VERSION php-$PHP_VERSION-xdebug-zend-server git

rm -rf /var/www
ln -s /vagrant/public /var/www

/usr/local/zend/bin/zendctl.sh restart

#!/usr/bin/env bash

PHP_VERSION="8.2"

# https://make.wordpress.org/hosting/handbook/server-environment/

sudo apt update && sudo apt upgrade
sudo apt install -y software-properties-common ca-certificates lsb-release apt-transport-https

LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php
LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/apache2

sudo apt update

sudo apt install -y "php${PHP_VERSION}" "php${PHP_VERSION}-fpm"

# The PHP extensions listed below are required for a WordPress site to work.
sudo apt install -y "php${PHP_VERSION}-json" "php${PHP_VERSION}-mysqli" "php${PHP_VERSION}-mysqlnd"

# The PHP extensions listed below are highly recommended in order to allow WordPress to operate optimally and to maximise compatibility with many popular plugins and themes.
sudo apt install -y "php${PHP_VERSION}-curl" "php${PHP_VERSION}-dom" "php${PHP_VERSION}-exif" "php${PHP_VERSION}-fileinfo" "php${PHP_VERSION}-hash" "php${PHP_VERSION}-igbinary" "php${PHP_VERSION}-imagick" "php${PHP_VERSION}-intl" "php${PHP_VERSION}-mbstring" "php${PHP_VERSION}-openssl" "php${PHP_VERSION}-pcre" "php${PHP_VERSION}-xml" "php${PHP_VERSION}-zip"

# The PHP extensions listed below are recommended to allow some WordPress cache (if necessary). APCu, Memcached, and Redis are alternatives of which only one needs to be used.
sudo apt install -y "php${PHP_VERSION}-apcu" "php${PHP_VERSION}-memcached" "php${PHP_VERSION}-opcache" "php${PHP_VERSION}-redis"

# For the sake of completeness, below is a list of the remaining PHP modules WordPress may use in certain situations or if other modules are unavailable. These are fallbacks or optional and not necessarily needed in an optimal environment, but installing them won’t hurt.
sudo apt install -y "php${PHP_VERSION}-bc" "php${PHP_VERSION}-filter" "php${PHP_VERSION}-image" "php${PHP_VERSION}-iconv" "php${PHP_VERSION}-shmop" "php${PHP_VERSION}-simplexml" "php${PHP_VERSION}-sodium" "php${PHP_VERSION}-xmlreader" "php${PHP_VERSION}-zlib"

# These extensions are used for file changes, such as updates and plugin/theme installation, when files aren’t writeable on the server.
sudo apt install -y "php${PHP_VERSION}-ssh2" "php${PHP_VERSION}-ftp" "php${PHP_VERSION}-sockets"

# System Packages
sudo apt install -y curl ghostscript imagemagick openssl

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/post_max_size = 8M/post_max_size = 128M/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/max_file_uploads = 20/max_file_uploads = 30/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/max_execution_time = 30/max_execution_time = 900/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/max_input_time = 60/max_input_time = 3000/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' "/etc/php/${PHP_VERSION}/fpm/php.ini"
service "php${PHP_VERSION}-fpm" restart

a2enmod proxy_fcgi ssl http2 expires headers rewrite remoteip
sudo a2dismod php*
sudo a2dismod mpm_prefork
sudo a2enmod mpm_event
sudo a2enmod proxy proxy_fcgi
sudo a2enconf "php${PHP_VERSION}-fpm"
systemctl restart apache2

sudo update-alternatives --set php "/usr/bin/php${PHP_VERSION}"
sudo update-alternatives --set phar "/usr/bin/phar${PHP_VERSION}"
sudo update-alternatives --set phar.phar "/usr/bin/phar.phar${PHP_VERSION}"
sudo update-alternatives --set phpize "/usr/bin/phpize${PHP_VERSION}"
sudo update-alternatives --set php-config "/usr/bin/php-config${PHP_VERSION}"

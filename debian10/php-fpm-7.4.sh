echo '-------------------------------------------------------------------------------- Install helper utils'
apt -y install lsb-release apt-transport-https ca-certificates
echo '-------------------------------------------------------------------------------- Install PHP'
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update &&  apt upgrade -y
apt -y install php7.4
echo '-------------------------------------------------------------------------------- Install PHP lib'
apt -y install \
            git \
            curl \
            imagemagick \
            libcurl3-dev \
            libicu-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
            libonig-dev \
            libmagickwand-dev \
            libpq-dev \
            libpng-dev \
            libxml2-dev \
            libzip-dev \
            zlib1g-dev \
            openssh-client \
            unzip \
            libcurl4-openssl-dev \
            libssl-dev \
echo '-------------------------------------------------------------------------------- Install PHP components'            
apt install php7.4-{bcmath,bz2,intl,gd,mbstring,mysql,zip,curl,exif,iconv,opcache}
echo '-------------------------------------------------------------------------------- Install Composer'            
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
chmod 755 /usr/local/bin/composer
       

echo '-------------------------------------------------------------------------------- Install PHP-FPM'
systemctl disable --now apache2
apt - y install nginx php7.4-fpm

echo '-------------------------------------------------------------------------------- Clean'
apt clean 
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
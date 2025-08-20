FROM php:8-apache
RUN apt-get update && \
	apt-get install -y \
	openssh-client \
	ca-certificates \
	git \
	nano \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libpng-dev  \
	less \
	libzip-dev \
	libmagickwand-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& pecl install imagick \
	&& update-ca-certificates 

RUN docker-php-ext-configure mysqli \
	&& docker-php-ext-install mysqli \
	&& docker-php-ext-configure exif \
	&& docker-php-ext-install exif \
	&& docker-php-ext-configure zip \
	&& docker-php-ext-install zip \
	&& docker-php-ext-configure gd \
	&& docker-php-ext-install gd \
	&& docker-php-ext-enable imagick \
	&& a2enmod ssl \
	&& openssl req -subj '/CN=example.com/O=My Company Name LTD./C=US' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem

COPY ${php.apache2.conf} /etc/apache2/apache2.conf
RUN a2ensite default-ssl && a2enmod rewrite
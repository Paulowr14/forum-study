FROM devilbox/php-fpm-8.0:latest

ARG USER
ARG UID

COPY composer.json package.json /usr/src/app/

ENV DOCKERIZE_VERSION 0.6.1

# Install dockerize so we can wait for containers to be ready
RUN curl -s -f -L -o /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/v$DOCKERIZE_VERSION/dockerize-linux-amd64-v$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
    && rm /tmp/dockerize.tar.gz

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        git \
        vim \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libzip-dev \
        unzip \
        zip \
        nodejs \
    && docker-php-ext-configure gd \
    && docker-php-ext-configure zip \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install \
        gd \
        exif \
        opcache \
        pdo_mysql \
        pcntl \
        zip \
    && rm -rf /var/lib/apt/lists/*;

# Install
RUN wget https://github.com/FriendsOfPHP/pickle/releases/download/v0.6.0/pickle.phar \
    && mv pickle.phar /usr/local/bin/pickle \
    && chmod +x /usr/local/bin/pickle \
    && pickle install redis \
    && docker-php-ext-enable redis;

COPY docker-config.ini /usr/local/etc/php/conf.d/docker-config.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer init --name=abc/adb --working-dir=/root/.composer --quiet --no-interaction
#   composer --no-interaction global require 'hirak/prestissimo'

RUN useradd -G www-data,root -u ${UID} -d /home/${USER} ${USER}
RUN mkdir -p /home/${USER}/.composer \
    && chown -R ${USER}:${USER} /home/${USER}

WORKDIR /usr/src/app

RUN alias a="php artisan"
RUN alias ls="ls --color"

USER ${USER}

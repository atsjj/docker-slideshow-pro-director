FROM atsjj/php:5.3.29
MAINTAINER Steve Jabour <steve@jabour.me>

# add jessie backports repository
RUN set -ex \
    && { \
      echo 'deb http://ftp.de.debian.org/debian jessie-backports main'; \
    } | tee -a /etc/apt/sources.list

# install dependencies
RUN apt-get update && \
    apt-get install -y \
      ffmpeg \
      imagemagick \
      libfreetype6-dev \
      libgd-dev \
      libjpeg-dev \
      libmysqlclient-dev \
      libpng-dev \
      zlib1g-dev

# work around php5-gd freetype2 bug (http://stackoverflow.com/a/26342869)
RUN mkdir /usr/include/freetype2/freetype && \
    ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# install php extensions
RUN docker-php-ext-configure gd \
      --with-gd \
      --with-jpeg-dir \
      --with-png-dir \
      --with-zlib-dir \
      --with-freetype-dir

RUN docker-php-ext-configure exif \
      --enable-exif

RUN docker-php-ext-install -j$(nproc) \
      exif \
      gd \
      mysqli

# clean-up after install
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# php-fpm on port 9000
EXPOSE 9000
WORKDIR /var/www

# run php-fpm on container start
CMD ["php-fpm"]

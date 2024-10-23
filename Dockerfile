# Use an official PHP 5.6 image with FPM (FastCGI Process Manager)
FROM php:5.6-fpm

# Disable APT security check for EOL release
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Update the sources list to use archived repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# Install dependencies for Nginx, PHP extensions, and OCI8
RUN apt-get update && apt-get install -y \
    nginx \
    libaio1 \
    unzip \
    wget \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    php5.6-mysql \
    php5.6-mbstring \
    php5.6-xml \
    php-pear \
    php5.6-dev

# Install Oracle Instant Client
RUN mkdir -p /opt/oracle
COPY ./client/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle
COPY ./client/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle

RUN cd /opt/oracle \
    && unzip instantclient-basic-linux.x64-12.2.0.1.0.zip \
    && unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip \
    && ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2 \
    && echo "/opt/oracle/instantclient_12_2" > /etc/ld.so.conf.d/oracle-instantclient.conf \
    && ldconfig

# Install OCI8 extension using PECL
RUN pecl install oci8-2.2.0 \
    && docker-php-ext-enable oci8 \
    && echo "extension=oci8.so" > /usr/local/etc/php/conf.d/oci8.ini

# Configure PHP to work with Nginx
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/lib \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql

# Copy custom Nginx configuration
COPY ./default /etc/nginx/sites-available/default

# Expose port 80 for Nginx
EXPOSE 80

# Start both Nginx and PHP-FPM services
CMD service nginx start && php-fpm
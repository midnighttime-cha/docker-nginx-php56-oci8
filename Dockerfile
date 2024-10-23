# Use official PHP 5.6 FPM image as the base
FROM php:5.6-fpm

RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list \
    && sed -i '/security.debian.org/s/^/#/' /etc/apt/sources.list \
    && apt-get update -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false

# Set environment variables for Oracle Instant Client
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_12_2"
ENV ORACLE_HOME="/opt/oracle/instantclient_12_2"

# Update package sources to use the Debian Stretch archive and remove stretch-updates


# Install necessary dependencies
RUN apt-get install -y \
    libaio1 \
    unzip \
    build-essential \
    libaio-dev \
    libssl-dev \
    curl \
    nginx \
    && apt-get clean


# Download and install Oracle Instant Client
RUN mkdir -p /opt/oracle

COPY ./client/instantclient-basic-linux.x64-12.2.0.1.0.zip /opt/oracle
COPY ./client/instantclient-sdk-linux.x64-12.2.0.1.0.zip /opt/oracle

RUN cd /opt/oracle \
    && unzip instantclient-basic-linux.x64-12.2.0.1.0.zip \
    && unzip instantclient-sdk-linux.x64-12.2.0.1.0.zip \
    && mkdir -p /opt/oracle/instantclient_12_2 \
    && ln -s /opt/oracle/instantclient_12_2/libclntsh.so.12.1 /opt/oracle/instantclient_12_2/libclntsh.so

# Install the OCI8 PHP extension (PHP Oracle support)
# Specify both the lib and the SDK include directories
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/opt/oracle/instantclient_12_2 \
    && docker-php-ext-install oci8

# Copy custom Nginx configuration
COPY ./nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
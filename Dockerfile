# Use an official PHP runtime as the base image
FROM php:8.1-fpm

# Set the working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    ibmcrypt-dev \
    libmagickwand-dev \
    zip \
    unzip \
    git \
    apache2-utils \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Clear the cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql  mcrypt

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy the Laravel application files to the container
COPY . .

# Install application dependencies and optimize autoloader
RUN composer install --optimize-autoloader --no-dev

# Set permissions for Laravel directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Specify the user and grant sudo access in the Docker file.

# Create a user named "appuser"
RUN useradd -m appuser

# Add the user to the "sudo" group and allow passwordless sudo
RUN usermod -aG sudo appuser
RUN echo 'appuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Expose port 8000 and start PHP-FPM server
EXPOSE 8000
CMD ["php-fpm"]

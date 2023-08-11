# Use an official PHP runtime as the base image
FROM php:8.1-fpm

# Set the working directory inside the container
# WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    apache2-utils

# Clear the cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- \
--install-dir=/usr/bin --filename=composer && chmod +x /usr/bin/composer 
# COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN sudo chmod -R 777 bootstrap/cache/

# Copy the Laravel application files to the container
WORKDIR /app
COPY . .

# Install application dependencies
RUN composer install

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

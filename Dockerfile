FROM php:7.3-apache

# Instalar dependencias de PHP
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    netcat \  # Instalar netcat para usar con wait-for-it
    && docker-php-ext-install pdo pdo_mysql zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos de la aplicación
COPY . /var/www/html

# Instalar dependencias de Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Dar permisos a las carpetas necesarias
RUN chown -R www-data:www-data storage bootstrap/cache

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Copiar el script wait-for-it
COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

# Exponer el puerto 80
EXPOSE 80

# Iniciar Apache usando wait-for-it para esperar la disponibilidad de MySQL
CMD ["wait-for-it", "mysql:3306", "--", "apache2-foreground"]

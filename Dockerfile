FROM php:8.0-apache

# Instalar dependencias y extensiones necesarias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos de la aplicación
COPY . /var/www/html

# Instalar dependencias de Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copiar archivo .env y generar clave de aplicación
COPY .env.example .env
RUN php artisan key:generate

# Cambiar permisos
RUN chown -R www-data:www-data storage bootstrap/cache

# Habilitar módulos de Apache
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Ejecutar Apache
CMD ["apache2-foreground"]

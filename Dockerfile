# Utilizar la imagen base de PHP con Apache
FROM php:8.0-apache

# Instalar extensiones de PHP necesarias
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    && docker-php-ext-install pdo pdo_mysql zip

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos de la aplicación
COPY . /var/www/html

# Instalar dependencias de Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copiar el archivo de entorno y generar la clave de la aplicación
COPY .env.example .env
RUN php artisan key:generate

# Dar permisos a las carpetas de almacenamiento
RUN chown -R www-data:www-data storage bootstrap/cache

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Iniciar Apache en primer plano
CMD ["apache2-foreground"]

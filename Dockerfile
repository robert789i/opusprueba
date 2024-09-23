FROM php:7.3-apache

# Instalar dependencias de PHP y Node.js
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    build-essential \
    && docker-php-ext-install pdo pdo_mysql zip

# Instalar Node.js y npm desde la fuente oficial (usa Node.js 14 para compatibilidad)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs

# Verificar versiones de node y npm
RUN node -v && npm -v

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos de la aplicación
COPY . /var/www/html

# Instalar dependencias de Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Instalar dependencias de npm con registro detallado
RUN npm install --verbose

# Compilar para producción con más detalle (utilizando verbose para registrar más información)
RUN npm run production --verbose || { echo "npm run production failed"; exit 1; }

# Dar permisos a las carpetas necesarias
RUN chown -R www-data:www-data storage bootstrap/cache

# Habilitar el módulo de reescritura de Apache
RUN a2enmod rewrite

# Exponer el puerto 80
EXPOSE 80

# Iniciar Apache en primer plano
CMD ["apache2-foreground"]

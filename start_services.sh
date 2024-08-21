#!/bin/sh

# Start PHP-FPM
php-fpm -D
if [ $? -ne 0 ]; then
  echo "Failed to start PHP-FPM"
  exit 1
fi

# Start NGINX
nginx -g 'daemon off;'
if [ $? -ne 0 ]; then
  echo "Failed to start NGINX"
  exit 1
fi

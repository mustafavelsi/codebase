# Use the official Rocky Linux 8 base image as an alternative to CentOS 8
FROM rockylinux:8

# Install EPEL repository
#RUN dnf install -y epel-release

# Install NGINX
RUN dnf install -y nginx

# Install PHP and PHP-FPM
RUN dnf install -y php php-fpm php-mysqlnd php-cli php-json php-opcache php-xml php-gd php-mbstring php-zip php-devel php-intl

# Configure PHP-FPM to use nginx user and group
RUN sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf \
    && sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf

# Create NGINX server block configuration
RUN echo 'server { \
    listen       80; \
    server_name  localhost; \
    root         /usr/share/nginx/html; \
    index        index.php index.html index.htm; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    location ~ \.php$ { \
        try_files $uri =404; \
        fastcgi_pass   unix:/run/php-fpm/www.sock; \
        fastcgi_index  index.php; \
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        include        fastcgi_params; \
    } \
    location ~ /\.ht { \
        deny  all; \
    } \
}' > /etc/nginx/conf.d/default.conf


# Create test PHP file
RUN echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

COPY . /usr/share/nginx/html/


# Set correct permissions and SELinux context on /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html 
RUN chmod -R 755 /usr/share/nginx/html
#    && chcon -R -t httpd_sys_content_t /usr/share/nginx/html || true


# Copy the startup script
COPY start_services.sh /usr/local/bin/start_services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start_services.sh

# Ensure the directory for the socket exists
RUN mkdir -p /run/php-fpm
RUN chown nginx:nginx /run/php-fpm
RUN chmod 755 /run/php-fpm



# Expose port 80
EXPOSE 80


# Start NGINX and PHP-FPM services

# CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

#CMD ["php-fpm -D && nginx -g 'daemon off;'"]

#CMD ["nginx", "-g", "daemon off;"]

# Use the startup script as the entry point
#CMD ["/usr/local/bin/start_services.sh"]


# Use the startup script as the entry point
ENTRYPOINT ["/usr/local/bin/start_services.sh"]

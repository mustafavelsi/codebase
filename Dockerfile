# Use Rocky Linux 9 as the base image
FROM rockylinux:9

# Install necessary packages: Nginx, PHP-FPM, and PHP extensions
#RUN dnf install -y epel-release && \
RUN dnf install -y nginx php php-fpm php-cli php-mysqlnd php-xml php-gd php-mbstring
# RUN dnf clean all

# Copy application files to the container
COPY . /var/www/html/

# Set the working directory
WORKDIR /var/www/html/

# Ensure the correct permissions
RUN chown -R nginx:nginx /var/www/html

# Configure PHP-FPM to listen on a Unix socket
RUN sed -i 's/listen = 127.0.0.1:9000/listen = \/run\/php-fpm.sock/' /etc/php-fpm.d/www.conf && \
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini

# Configure Nginx to use PHP-FPM
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /var/www/html; \
    index index.php index.html index.htm; \
    location / { \
        try_files $uri $uri/ =404; \
    } \
    location ~ \.php$ { \
        include fastcgi_params; \
        fastcgi_pass unix:/run/php-fpm.sock; \
        fastcgi_index index.php; \
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \
        include fastcgi_params; \
    } \
    location ~ /\.ht { \
        deny all; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx and PHP-FPM services
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

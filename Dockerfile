FROM localstack/localstack:latest

# Cài đặt Nginx
RUN apt-get update && apt-get install -y nginx

# Tạo thư mục cho trang web
RUN mkdir -p /var/www/html

# Copy file cấu hình Nginx
COPY default /etc/nginx/sites-available/default

# Copy trang web vào thư mục /var/www/html
COPY index.html /var/www/html/

# Expose cổng 80
EXPOSE 80

# Chạy Nginx và LocalStack
CMD ["sh", "-c", "nginx -g 'daemon off;' & localstack start"]

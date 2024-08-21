FROM localstack/localstack:latest

# Cài đặt Python
RUN apt-get update && apt-get install -y python3 python3-pip

# Tạo thư mục cho trang web
RUN mkdir -p /var/www/html

# Sao chép tệp index.html vào thư mục làm việc
COPY index.html /var/www/html/

# Cài đặt máy chủ HTTP Python
EXPOSE 8000 4566

# Chạy máy chủ HTTP Python và LocalStack
CMD python3 -m http.server 8000 --directory /var/www/html & localstack start --host

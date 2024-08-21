FROM localstack/localstack:latest

# Expose c4566
EXPOSE 4566

# Run LocalStack
CMD ["localstack", "start", "--host"]
